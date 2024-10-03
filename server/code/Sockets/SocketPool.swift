import Foundation

import HelloCore

enum SocketState {
  case closed
  case readyToRead
  case readyToWrite
  case readyToReadAndWrite
  case idle
}

class PoolCancelSignal {
  
  private let inputFD: Int32
  let outputFD: Int32
  
  init() {
    var fds: [Int32] = [0, 0]
    guard pipe(&fds) == 0 else {
      fatalError("Failed to pipe")
    }
    inputFD = fds[1]
    outputFD = fds[0]
    guard fcntl(inputFD, F_SETFL, O_NONBLOCK) >= 0 && fcntl(outputFD, F_SETFL, O_NONBLOCK) >= 0 else {
      fatalError()
    }
  }
  
  func cancel() {
    var cancelString = "1"
    write(inputFD, &cancelString, 1)
  }
  
  func reset() {
    var recieveBuffer: [UInt8] = [UInt8](repeating: 0, count: 10)
    read(outputFD, &recieveBuffer, 10)
  }
}

final class PollActorSerialExecutor: SerialExecutor {
  private let queue = DispatchQueue(label: "SocketPollQueue")
  
  func enqueue(_ job: UnownedJob) {
    queue.async {
      job.runSynchronously(on: self.asUnownedSerialExecutor())
    }
  }
  
  func asUnownedSerialExecutor() -> UnownedSerialExecutor {
    return UnownedSerialExecutor(ordinary: self)
  }
}

@globalActor final public actor SocketPollActor: GlobalActor {
  public static let shared: SocketPollActor = SocketPollActor()
  
  public nonisolated var unownedExecutor: UnownedSerialExecutor { Self.sharedUnownedExecutor }
  
  public static var sharedUnownedExecutor: UnownedSerialExecutor = PollActorSerialExecutor().asUnownedSerialExecutor()
}

@globalActor final public actor SocketPoolActor: GlobalActor {
  public static let shared: SocketPoolActor = SocketPoolActor()
}

@SocketPollActor
enum SocketPollerlll {
  static func pollSocket(_ pollfds: [pollfd], _ count: nfds_t, _ timeout: Int32) -> [pollfd] {
    var pollfds = pollfds
    poll(&pollfds, nfds_t(pollfds.count), -1)
    return pollfds
  }
}

@SocketPoolActor
class SocketPoller {
  
  var cancelSocket = PoolCancelSignal()
  var readObservedSockets: Set<Int32> = []
  var writeObservedSockets: Set<Int32> = []
  var stateUpdateListener: ([Int32: SocketState]) -> Void = { _ in }
  
  nonisolated init() {
    Task { @SocketPoolActor in
      await self.pollEventLoop()
    }
  }
  
  func update(readObservedSockets: Set<Int32>) {
    guard self.readObservedSockets != readObservedSockets else { return }
    self.readObservedSockets = readObservedSockets
    cancelSocket.cancel()
  }
  
  func update(writeObservedSockets: Set<Int32>) {
    guard self.writeObservedSockets != writeObservedSockets else { return }
    self.writeObservedSockets = writeObservedSockets
    cancelSocket.cancel()
  }
  
  private func pollEventLoop() async {
    var sleepInterval: TimeInterval = 0.01
    while true {
      var pollfdMap: [Int32: pollfd] = [:]
      for socket in ([cancelSocket.outputFD] + readObservedSockets) {
        pollfdMap[socket] = pollfd(fd: socket, events: Int16(POLLIN | POLLPRI), revents: 0)
      }
      for socket in (writeObservedSockets) {
        if var pollFD = pollfdMap[socket] {
          pollFD.events |= Int16(POLLOUT)
          pollfdMap[socket] = pollFD
        } else {
          pollfdMap[socket] = pollfd(fd: socket, events: Int16(POLLOUT), revents: 0)
        }
      }
      var pollfds = [pollfd](pollfdMap.values)
//      Log.verbose("waiting on \(pollfds.count - 1) sockets", context: "Poll")
//      pollfds = await SocketPollerlll.pollSocket(pollfds, nfds_t(pollfds.count), -1)
      poll(&pollfds, nfds_t(pollfds.count), 0)
      cancelSocket.reset()
      var socketStates: [Int32: SocketState] = [:]
      for pollSocket in pollfds where pollSocket.fd != cancelSocket.outputFD {
        socketStates[pollSocket.fd] = .idle
        if pollSocket.revents != 0 {
          if pollSocket.revents & Int16(POLLERR | POLLHUP | POLLNVAL) != 0 {
            socketStates[pollSocket.fd] = .closed
            readObservedSockets.remove(pollSocket.fd)
            writeObservedSockets.remove(pollSocket.fd)
          } else if pollSocket.revents & Int16(POLLIN | POLLPRI) != 0 && pollSocket.revents & Int16(POLLOUT) != 0 {
            socketStates[pollSocket.fd] = .readyToReadAndWrite
            readObservedSockets.remove(pollSocket.fd)
            writeObservedSockets.remove(pollSocket.fd)
          } else if pollSocket.revents & Int16(POLLIN | POLLPRI) != 0 {
            socketStates[pollSocket.fd] = .readyToRead
            readObservedSockets.remove(pollSocket.fd)
          } else if pollSocket.revents & Int16(POLLOUT) != 0 {
            socketStates[pollSocket.fd] = .readyToWrite
            writeObservedSockets.remove(pollSocket.fd)
          } else {
            Log.error("Unhandled events \(pollSocket.revents)", context: "Poll")
          }
        }
      }
      Log.verbose("Done", context: "Poll")
      if socketStates.contains(where: { $0.value != .idle }) {
        sleepInterval = 0.005
        let socketStates = socketStates
        self.stateUpdateListener(socketStates)
        try? await Task.sleep(seconds: sleepInterval)
      } else {
        if sleepInterval < 1 {
          sleepInterval += 0.002
        }
        try? await Task.sleep(seconds: sleepInterval)
      }
    }
  }
}

@SocketPoolActor
class SocketPool {
  
  static var main: SocketPool = SocketPool()
  
  var poller: SocketPoller = SocketPoller()
  
  nonisolated init() {
    Task { @SocketPoolActor in
      poller.stateUpdateListener = { states in
        Task { await self.pollStateUpdate(states) }
      }
    }
  }
  
  var pollTask: Task<[Int32: SocketState], any Error>?
  var writeSocketListeners: [Int32: [CheckedContinuation<Void, Error>]] = [:]
  var readSocketListeners: [Int32: [CheckedContinuation<Void, Error>]] = [:]
  
  public func pollStateUpdate(_ socketStates: [Int32: SocketState]) async {
    for socketState in socketStates where socketState.value != .idle {
      let readContinuations = readSocketListeners[socketState.key]
      let writeContinuations = writeSocketListeners[socketState.key]
      switch socketState.value {
      case .closed:
        readSocketListeners[socketState.key] = nil
        writeSocketListeners[socketState.key] = nil
        readContinuations?.forEach { $0.resume(throwing: SocketError.closed) }
        writeContinuations?.forEach { $0.resume(throwing: SocketError.closed) }
      case .readyToReadAndWrite:
        readSocketListeners[socketState.key] = nil
        writeSocketListeners[socketState.key] = nil
        readContinuations?.forEach { $0.resume() }
        writeContinuations?.forEach { $0.resume() }
      case .readyToRead:
        readSocketListeners[socketState.key] = nil
        readContinuations?.forEach { $0.resume() }
      case .readyToWrite:
        writeSocketListeners[socketState.key] = nil
        writeContinuations?.forEach { $0.resume() }
      case .idle: continue
      }
    }
  }
  
  func waitUntilReadable(_ socket: Int32) async throws -> Void {
    try await withCheckedThrowingContinuation { continuation in
      addReadListener(continuation, to: socket)
      poller.update(readObservedSockets: Set(readSocketListeners.keys))
    }
  }
  
  func waitUntilWriteable(_ socket: Int32) async throws -> Void {
    try await withCheckedThrowingContinuation { continuation in
      addWriteListener(continuation, to: socket)
      poller.update(writeObservedSockets: Set(writeSocketListeners.keys))
    }
  }
  
  private func addReadListener(_ continuation: CheckedContinuation<Void, Error>, to fd: Int32) {
    readSocketListeners[fd] = (readSocketListeners[fd] ?? []) + [continuation]
  }
  
  private func addWriteListener(_ continuation: CheckedContinuation<Void, Error>, to fd: Int32) {
    writeSocketListeners[fd] = (writeSocketListeners[fd] ?? []) + [continuation]
  }
}

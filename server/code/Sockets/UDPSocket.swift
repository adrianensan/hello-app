import Foundation

import HelloCore

public struct UDPPacket: Sendable {
  public var originAddress: NetworkAddress
  public var bytes: [UInt8]
}

@SocketActor
public class UDPSocket: Socket {
  
  var port: UInt16
  
  nonisolated public init(socketFD: Int32, port: UInt16) throws {
    self.port = port
    try super.init(socketFD: socketFD)
  }
  
  public func send(data: [UInt8], to address: NetworkAddress) async throws {
    var bytesToSend = data.count
    var bytesSent = 0
    while bytesToSend > 0 {
      let passBytesSent = try sendDataPass(data: [UInt8](data[bytesSent...]), to: address)
      if passBytesSent <= 0 {
        throw SocketError.closed
      }
      bytesSent += passBytesSent
      bytesToSend -= bytesSent
    }
  }
  
  func sendDataPass(data: [UInt8], to address: NetworkAddress) throws -> Int {
    Log.verbose(context: "UDP Socket", "Sending \(data.count) bytes to \(address.string) on \(socketFileDescriptor)")
    var toAddr = address.systemAddr
    return Int(sendto(socketFileDescriptor, data, data.count, Socket.socketSendFlags, &toAddr, socklen_t(MemoryLayout<sockaddr_in>.size)))
  }
  
  func rawRecieveData() throws -> UDPPacket {
    var recieveBuffer: [UInt8] = [UInt8](repeating: 0, count: Socket.bufferSize)
    var remoteAddr = sockaddr()
    var remoteAddrLength = socklen_t(MemoryLayout<sockaddr>.size)
    let bytesRead = recvfrom(socketFileDescriptor, &recieveBuffer, Socket.bufferSize, 0, &remoteAddr, &remoteAddrLength)
    guard bytesRead > 0 else { throw SocketError.cantReadYet }
    Log.verbose(context: "UDP Socket", "Read \(bytesRead) bytes from \(socketFileDescriptor)")
    return UDPPacket(originAddress: try NetworkAddress(from: remoteAddr),
                     bytes: [UInt8](recieveBuffer[..<Int(bytesRead)]))
  }
  
  func recievePacket() async throws -> UDPPacket {
    var errorLoopCounter = 0
    while true {
      do {
        return try rawRecieveData()
      } catch SocketError.cantReadYet {
        try await SocketPool.main.waitUntilReadable(socketFileDescriptor)
      }
      guard errorLoopCounter < 3 else { throw SocketError.errorLoop }
      errorLoopCounter += 1
    }
  }
}

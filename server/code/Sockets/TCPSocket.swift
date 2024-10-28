import Foundation
import CoreFoundation

import HelloCore
import OpenSSL

@SocketActor
public class TCPSocket: Socket {
  func sendDataPass(data: [UInt8]) throws -> Int {
    Log.verbose(context: "Socket", "Sending \(data.count) bytes to \(socketFileDescriptor)")
    let bytesSent = send(socketFileDescriptor, data, data.count, Socket.socketSendFlags)
    guard bytesSent > 0 else {
      switch errno {
      case EAGAIN, EWOULDBLOCK: throw SocketError.cantWriteYet
      default: throw SocketError.closed
      }
    }
    return bytesSent
  }
  
  func sendData(data: [UInt8]) async throws {
    var bytesToSend = data.count
    var bytesSent = 0
    var errorLoopCounter = 0
    while bytesToSend > 0 {
      do {
        let passBytesSent = try sendDataPass(data: [UInt8](data[bytesSent...]))
        bytesSent += passBytesSent
        bytesToSend -= passBytesSent
        errorLoopCounter = 0
      } catch SocketError.cantWriteYet {
        guard errorLoopCounter < 3 else { throw SocketError.errorLoop }
        errorLoopCounter += 1
        try await SocketPool.main.waitUntilWriteable(socketFileDescriptor)
      } catch SocketError.cantReadYet {
        guard errorLoopCounter < 3 else { throw SocketError.errorLoop }
        errorLoopCounter += 1
        try await SocketPool.main.waitUntilReadable(socketFileDescriptor)
      }
    }
  }
  
  func rawRecieveData() throws -> [UInt8] {
    var recieveBuffer: [UInt8] = [UInt8](repeating: 0, count: Socket.bufferSize)
    let bytesRead = recv(socketFileDescriptor, &recieveBuffer, Socket.bufferSize, 0)
    guard bytesRead > 0 else {
      switch errno {
      case EAGAIN, EWOULDBLOCK: throw SocketError.cantReadYet
      default: throw SocketError.closed
      }
    }
    Log.verbose(context: "Socket", "Read \(bytesRead) bytes from \(socketFileDescriptor)")
    return [UInt8](recieveBuffer[..<Int(bytesRead)])
  }
  
  func peakDataBlock() async throws -> [UInt8] {
    var errorLoopCounter = 0
    while true {
      do {
        var recieveBuffer: [UInt8] = [UInt8](repeating: 0, count: Socket.bufferSize)
        let bytesRead = recv(socketFileDescriptor, &recieveBuffer, Socket.bufferSize, Int32(MSG_PEEK))
        guard bytesRead > 0 else {
          switch errno {
          case EAGAIN, EWOULDBLOCK: throw SocketError.cantReadYet
          default: throw SocketError.closed
          }
        }
        return [UInt8](recieveBuffer[..<bytesRead])
      } catch SocketError.cantReadYet {
        try await SocketPool.main.waitUntilReadable(socketFileDescriptor)
      } catch SocketError.cantWriteYet {
        try await SocketPool.main.waitUntilWriteable(socketFileDescriptor)
      }
      guard errorLoopCounter < 3 else { throw SocketError.errorLoop }
      errorLoopCounter += 1
    }
  }
  
  func recieveDataBlock() async throws -> [UInt8] {
    var errorLoopCounter = 0
    while true {
      do {
        return try rawRecieveData()
      } catch SocketError.cantReadYet {
        try await SocketPool.main.waitUntilReadable(socketFileDescriptor)
      } catch SocketError.cantWriteYet {
        try await SocketPool.main.waitUntilWriteable(socketFileDescriptor)
      }
      guard errorLoopCounter < 3 else { throw SocketError.errorLoop }
      if errorLoopCounter > 0 {
        try await Task.sleep(seconds: 0.01)
      }
      errorLoopCounter += 1
    }
  }
}

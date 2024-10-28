import Foundation
import CoreFoundation

import HelloCore

@SocketActor
class ServerSocket: Socket {
    
  nonisolated static let acceptBacklog: Int32 = 20
  
  let usingTLS: Bool
  
  nonisolated init(port: UInt16, usingTLS: Bool) throws {
    self.usingTLS = usingTLS
    let listeningSocket = socket(AF_INET, SocketType.tcp.systemValue, 0)
    
    guard listeningSocket >= 0 else {
      throw SocketError.initFail
    }
    
    try super.init(socketFD: listeningSocket)
    
    try bindForInbound(to: port)
    
    guard listen(socketFileDescriptor, ServerSocket.acceptBacklog) != -1 else {
      Log.error(context: "Socket", "Failed to listen on port \(port).")
      throw SocketError.listenFail
    }
  }
  
  deinit {
    close(socketFileDescriptor)
  }
  
  func acceptConnection() async throws -> ClientConnection {
    var clientAddrressStruct = sockaddr()
    var clientAddressLength = socklen_t(MemoryLayout<sockaddr>.size)
    var newConnectionFD: Int32 = -1
    while true {
      Log.verbose(context: "Router", "accept attempt")
      clientAddrressStruct = sockaddr()
      clientAddressLength = socklen_t(MemoryLayout<sockaddr>.size)
      newConnectionFD = accept(socketFileDescriptor, &clientAddrressStruct, &clientAddressLength)
      guard newConnectionFD > 0 else {
        switch errno {
        case EAGAIN, EWOULDBLOCK:
          try await SocketPool.main.waitUntilReadable(socketFileDescriptor)
          Log.verbose(context: "Router", "Ready to accept")
          continue
        default:
          throw SocketError.closed
        }
      }
      break
    }
    
    let clientAddress = try NetworkAddress(from: clientAddrressStruct)
    
    if usingTLS {
      return try SSLClientConnection(socket: TLSSocket(socketFD: newConnectionFD), clientAddress: clientAddress)
    } else {
      return try ClientConnection(socket: TCPSocket(socketFD: newConnectionFD), clientAddress: clientAddress)
    }
  }
}

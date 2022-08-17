//import Foundation
//
//import HelloCore
//
//public struct AuthTokenPersistor: PersistenceProperty {
//  
//  public var defaultValue: String? { nil }
//  
//  public var location: PersistenceType { .keychain(key: "authToken") }
//  
//  public var key: APIPersistenceKey { .authToken }
//}
//
//public extension PersistenceProperty where Self == AuthTokenPersistor {
//  static var authToken: AuthTokenPersistor {
//    AuthTokenPersistor()
//  }
//}

import Foundation

public protocol PersistenceKey: Hashable, Sendable {
  static var persistence: OFPersistence<Self> { get }
}

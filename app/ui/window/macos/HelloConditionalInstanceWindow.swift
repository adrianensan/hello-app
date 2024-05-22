#if os(macOS)
import Foundation

@MainActor
public protocol HelloConditionalInstanceWindow<Key>: HelloWindow {
  
  associatedtype Key: Hashable
  
  init(_ key: Key)
  
  static var current: [Key: Self] { get set }
}

public extension HelloConditionalInstanceWindow {
  static func bringToFront(key: Key) {
    current[key]?.show()
  }
  
  static func show(key: Key) {
    if let current = current[key] {
      current.show()
    } else {
      let newInstance = Self(key)
      newInstance.onCloseSupplementary = { Self.current[key] = nil }
      current[key] = newInstance
      newInstance.show()
    }
  }
  
  static func close(key: Key) {
    current[key]?.close()
    current[key] = nil
  }
}
#endif

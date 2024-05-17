#if os(macOS)
import Foundation

@MainActor
public protocol HelloConditionalInstanceWindow<Key>: HelloWindow {
  
  associatedtype Key: Hashable
  
  init(_ key: Key)
  
  static var current: [Key: Self] { get set }
  
  var key: Key { get }
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
      current[key] = newInstance
      newInstance.show()
    }
  }
  
  func close() {
    nsWindow.close()
    Self.current[key] = nil
  }
  
  static func close(key: Key) {
    current[key]?.close()
    current[key] = nil
  }
  
  func windowWillClose(_ notification: Notification) {
    Self.current[key] = nil
  }
}
#endif

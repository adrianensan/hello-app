#if os(macOS)
import Foundation

@MainActor
public protocol OFConditionalInstanceWindow<Key>: OFWindow {
  
  associatedtype Key: Hashable
  
  static var current: [Key: Self] { get set }
  
  var key: Key { get }
  
  static func newInstance(for key: Key) -> Self
}

public extension OFConditionalInstanceWindow {
  static func bringToFront(key: Key) {
    current[key]?.show()
  }
  
  static func show(key: Key) {
    if let current = current[key] {
      current.show()
    } else {
      let newInstance = newInstance(for: key)
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

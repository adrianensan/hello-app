#if os(macOS)
import Foundation
import AppKit

@MainActor
public protocol OFSingleInstanceWindow: OFWindow {
  
  static var current: Self? { get set }
  
  static var newInstance: Self { get }
}

public extension OFSingleInstanceWindow {
  static func bringToFront() {
    current?.bringToFront()
  }
  
  static func currentCreatingIfNeeded() -> Self {
    if let current {
      return current
    } else {
      let newInstance = newInstance
      current = newInstance
      return newInstance
    }
  }
  
  static func show() {
    currentCreatingIfNeeded().show()
  }
  
  func close() {
    nsWindow.close()
    Self.current = nil
  }
  
  static func close() {
    current?.nsWindow.close()
    current = nil
  }
}
#endif

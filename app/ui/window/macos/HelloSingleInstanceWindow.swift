#if os(macOS)
import Foundation
import AppKit

@MainActor
public protocol HelloSingleInstanceWindow: HelloWindow {
  
  init()
  
  static var current: Self? { get set }
}

public extension HelloSingleInstanceWindow {
  
  static var isCreated: Bool { current != nil }
  
  static func bringToFront() {
    current?.bringToFront()
  }
  
  static func currentCreatingIfNeeded() -> Self {
    if let current {
      return current
    } else {
      let newInstance = Self()
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

#if os(macOS)
import Foundation
import AppKit

@MainActor
public protocol HelloSingleInstanceWindow: HelloDefaultWindow {
  
  init()
  
  static var current: Self? { get set }
}

@MainActor
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
      newInstance.onCloseSupplementary = {
        if newInstance === Self.current {
          Self.current = nil
        }
      }
      current = newInstance
      return newInstance
    }
  }
  
  static func show() {
    currentCreatingIfNeeded().show()
  }
  
  static func close() {
    current?.nsWindow.close()
    current = nil
  }
}
#endif

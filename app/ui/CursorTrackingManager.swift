#if os(macOS)
import AppKit

import HelloCore

public protocol CursorTrackingDelegate: AnyObject {
  func cursorPositionDidChage(to point: CGPoint)
}

@MainActor
public class CursorTrackingManager {
  
  public static let main = CursorTrackingManager()
  
  public private(set) var currentMousePosition: CGPoint = .zero
  
  private var isTracking: Bool = false
  private var localMonitor: Any?
  private var globalMonitor: Any?
  private var delegates: [Weak<AnyObject>] = []
  
  private init() {
    setup()
  }
  
  private func setup() {
    globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
      guard let self else { return }
      let cursorPosition = NSEvent.mouseLocation// event.locationInWindow + (event.window?.frame.origin ?? .zero)
      self.cursorPositionChanged(to: cursorPosition)
    }
    
    localMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
      guard let self else { return event }
      let cursorPosition = NSEvent.mouseLocation//event.locationInWindow + (event.window?.frame.origin ?? .zero)
      self.cursorPositionChanged(to: cursorPosition)
      return event
    }
    let currentMousePosition: CGPoint = NSEvent.mouseLocation
    self.currentMousePosition = currentMousePosition
  }
  
  private func cursorPositionChanged(to position: CGPoint) {
    currentMousePosition = position
    for (i, wrappedDelegate) in delegates.enumerated().reversed() {
      guard let delegate = wrappedDelegate.value as? any CursorTrackingDelegate else {
        delegates.remove(at: i)
        continue
      }
      delegate.cursorPositionDidChage(to: position)
    }
  }
  
  public func add(delegate: some CursorTrackingDelegate) {
    delegates.append(Weak(value: delegate))
  }
  
//  public func startTracking(handler: @escaping (CGPoint) -> Void) {
//    guard !isTracking else { return }
//    isTracking = true
//    globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
//      guard let self else { return }
//      let cursorPosition = event.locationInWindow + (event.window?.frame.origin ?? .zero)
//      self.currentMousePosition = cursorPosition
//      handler(cursorPosition)
////      ThrowFullscreenOverlayModel.main.scene2D?.setCursorPosition(cursorPosition)
//    }
//    
//    localMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
//      guard let self else { return event }
//      let cursorPosition = event.locationInWindow + (event.window?.frame.origin ?? .zero)
//      self.currentMousePosition = cursorPosition
//      handler(cursorPosition)
////      ThrowFullscreenOverlayModel.main.scene2D?.setCursorPosition(cursorPosition)
//      return event
//    }
//    let currentMousePosition: CGPoint = NSEvent.mouseLocation
//    self.currentMousePosition = currentMousePosition
//    handler(currentMousePosition)
////    ThrowFullscreenOverlayModel.main.scene2D?.setCursorPosition(currentMousePosition)
//  }
  
//  public func stopTracking() {
//    guard isTracking else { return }
//    isTracking = false
//    if let globalMonitor {
//      NSEvent.removeMonitor(globalMonitor)
//    }
//    if let localMonitor {
//      NSEvent.removeMonitor(localMonitor)
//    }
//  }
}
#endif

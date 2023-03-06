#if os(macOS)
import AppKit

import HelloCore

@MainActor
public class CursorTrackingManager {
  
  public static let main = CursorTrackingManager()
  
  public private(set) var currentMousePosition: CGPoint = .zero
  
  private var isTracking: Bool = false
  private var localMonitor: Any?
  private var globalMonitor: Any?
  
  public func startTracking(handler: @escaping (CGPoint) -> Void) {
    guard !isTracking else { return }
    isTracking = true
    globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
      guard let self else { return }
      let cursorPosition = event.locationInWindow + (event.window?.frame.origin ?? .zero)
      self.currentMousePosition = cursorPosition
      handler(cursorPosition)
//      ThrowFullscreenOverlayModel.main.scene2D?.setCursorPosition(cursorPosition)
    }
    
    localMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
      guard let self else { return event }
      let cursorPosition = event.locationInWindow + (event.window?.frame.origin ?? .zero)
      self.currentMousePosition = cursorPosition
      handler(cursorPosition)
//      ThrowFullscreenOverlayModel.main.scene2D?.setCursorPosition(cursorPosition)
      return event
    }
    let currentMousePosition: CGPoint = NSEvent.mouseLocation
    self.currentMousePosition = currentMousePosition
    handler(currentMousePosition)
//    ThrowFullscreenOverlayModel.main.scene2D?.setCursorPosition(currentMousePosition)
  }
  
  public func stopTracking() {
    guard isTracking else { return }
    isTracking = false
    if let globalMonitor {
      NSEvent.removeMonitor(globalMonitor)
    }
    if let localMonitor {
      NSEvent.removeMonitor(localMonitor)
    }
  }
}
#endif

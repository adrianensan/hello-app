#if os(macOS)
import SwiftUI

import HelloCore

open class HelloSubWindow: HelloWindow {
  
  private var anchor: WindowAnchor
  
  private var targetOrigin: CGPoint {
    var target = anchor.point - nsWindow.frame.size
    switch anchor.alignment.horizontal {
    case .center: target.x += 0.5 * nsWindow.frame.size.width
    case .leading: target.x += nsWindow.frame.size.width
    default: ()
    }
    
    switch anchor.alignment.vertical {
    case .center: target.y += 0.5 * nsWindow.frame.size.height
    case .bottom: target.y += nsWindow.frame.size.height
    default: ()
    }
    
    if let screenFrame = screen?.visibleFrame {
      let topClip = (target.y + nsWindow.frame.height) - screenFrame.maxY
      if topClip > 0 {
        target.y -= topClip
      }
      
      let bottomClip = screenFrame.minY - target.y
      if bottomClip > 0 {
        target.y += bottomClip
      }
      
      let leadingClip = screenFrame.minX - target.x
      if leadingClip > 0 {
        target.x += leadingClip
      }
      
      let trailingClip = (target.x + nsWindow.frame.width) - screenFrame.maxX
      if trailingClip > 0 {
        target.x -= trailingClip
      }
    }
    return target
  }
  
  private var autoCloseBehaviourOption: HelloWindow.AutoCloseBehaviour
  
  override public var autoCloseBehaviour: HelloWindow.AutoCloseBehaviour { autoCloseBehaviourOption }
  
  public init(id: String = .uuid,
              anchor: WindowAnchor,
              autoCloseBehaviour: HelloWindow.AutoCloseBehaviour = .onFocusLost,
              parentWindow: HelloWindow? = nil,
              windowLevel: NSWindow.Level = .tornOffMenu,
              content: @autoclosure () -> some View,
              canBecomeMain: Bool = false,
              canBecomeKey: Bool? = nil) {
    self.anchor = anchor
    autoCloseBehaviourOption = autoCloseBehaviour
    super.init(view: content().closableByEscape(),
               id: id,
               parentWindow: parentWindow,
               size: .fixedAuto,
               windowFlags: [.fullSizeContentView, .titled, .closable],
               forceKey: canBecomeKey ?? (autoCloseBehaviour == .onHoverLost || autoCloseBehaviour == .onHoverLostRespectingMouseInWindow ? false : nil),
               canBecomeMainOverride: canBecomeMain)
    draggableArea = .none
    nsWindow.collectionBehavior = [.transient, .ignoresCycle, .stationary]
    nsWindow.level = windowLevel
    nsWindow.backgroundColor = .clear
    nsWindow.isOpaque = false
  }
  
  override public var hideWindowButtons: Bool { true }
  
  override public func onResize() {
    let targetOrigin = targetOrigin
    if nsWindow.frame.origin != targetOrigin {
      nsWindow.setFrame(CGRect(origin: targetOrigin, size: nsWindow.frame.size), display: true)
    }
  }
  
  override public func onMove() {
    let targetOrigin = targetOrigin
    if nsWindow.frame.origin != targetOrigin {
      nsWindow.setFrame(CGRect(origin: targetOrigin, size: nsWindow.frame.size), display: true)
    }
  }
}
#endif

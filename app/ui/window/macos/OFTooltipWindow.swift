#if os(macOS)
import SwiftUI

import HelloCore

public class OFTooltipWindow: OFWindow {
  
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
    return target
  }
  
  public init(anchor: WindowAnchor, content: @autoclosure () -> some View) {
    self.anchor = anchor
    super.init(view: content(),
               size: .fixedAuto,
               windowFlags: [.borderless])
    draggableArea = .none
    nsWindow.ignoresMouseEvents = true
    nsWindow.collectionBehavior = [.transient, .ignoresCycle, .stationary]
    nsWindow.level = .tornOffMenu
    nsWindow.backgroundColor = .clear
  }
  
  override public func show() {
    nsWindow.orderFrontRegardless()
  }
  
  override public func onResize() {
    if nsWindow.frame.origin != targetOrigin {
      nsWindow.setFrameOrigin(targetOrigin)
    }
  }
  
  override public func onMove() {
    if nsWindow.frame.origin != targetOrigin {
      nsWindow.setFrameOrigin(targetOrigin)
    }
  }
}
#endif

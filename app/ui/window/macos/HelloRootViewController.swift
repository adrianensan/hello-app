#if os(macOS)
import SwiftUI

@MainActor
@Observable
public class HelloWindowManager {
  
  public var popupView: AnyView?
  @ObservationIgnored var popupViewPosition: CGPoint = .zero
  @ObservationIgnored weak var window: HelloWindow?
  
  public func showPopup<Content: View>(_ view: Content, at position: CGPoint) {
    popupViewPosition = position
    popupView = AnyView(view)
  }
  
  public func dismissPopup() {
    guard popupView != nil else { return }
    popupView = nil
  }
}

public class HelloRootViewController<Content: View>: NSViewController {
  
  // When using SwiftUI as the rootview alongside full window content, it becomes impossible to
  // properly ignore safe area (same is true on iOS).
  // Force safe area to be zero and save the actual safe area in an object
  @MainActor
  class NoSafeAreaNSView: NSHostingView<HelloWindowRootView<Content>> {
    
    var realSafeAreaInsets: NSEdgeInsets { super.safeAreaInsets }
    
    var onMouseMoved: ((CGPoint) -> Void)?
    var onMouseEntered: (() -> Void)?
    var onMouseExited: (() -> Void)?
    var onCursorUpdate: (() -> Void)?
    
    override func contentCompressionResistancePriority(for orientation: NSLayoutConstraint.Orientation) -> NSLayoutConstraint.Priority {
      NSLayoutConstraint.Priority(14)
    }
    override var safeAreaInsets: NSEdgeInsets { NSEdgeInsets() }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    
    override func mouseEntered(with event: NSEvent) {
      super.mouseEntered(with: event)
      onMouseEntered?()
    }
    
    override func mouseExited(with event: NSEvent) {
      super.mouseExited(with: event)
      onMouseExited?()
    }
    
    override func mouseMoved(with event: NSEvent) {
      super.mouseMoved(with: event)
      onMouseMoved?(event.locationInWindow)
    }
    
    override func cursorUpdate(with event: NSEvent) {
      super.cursorUpdate(with: event)
      onCursorUpdate?()
    }
    
//    override var mouseDownCanMoveWindow: Bool { true }
  }
  
  let uiProperties: UIProperties
  let noSafeAreaNSView: NoSafeAreaNSView
  
  var onMouseMoved: ((CGPoint) -> Void)? {
    get { noSafeAreaNSView.onMouseMoved }
    set { noSafeAreaNSView.onMouseMoved = newValue }
  }
  var onMouseEntered: (() -> Void)? {
    get { noSafeAreaNSView.onMouseEntered }
    set { noSafeAreaNSView.onMouseEntered = newValue }
  }
  var onMouseExited: (() -> Void)? {
    get { noSafeAreaNSView.onMouseExited }
    set { noSafeAreaNSView.onMouseExited = newValue }
  }
  var onCursorUpdate: (() -> Void)? {
    get { noSafeAreaNSView.onCursorUpdate }
    set { noSafeAreaNSView.onCursorUpdate = newValue }
  }
  
  public init(rootView: Content, uiProperties: UIProperties) {
    self.uiProperties = uiProperties
    noSafeAreaNSView = NoSafeAreaNSView(rootView: HelloWindowRootView(uiProperties: uiProperties) { rootView })
    if uiProperties.size != .zero {
      noSafeAreaNSView.frame.size = uiProperties.size
    }
    super.init(nibName: nil, bundle: nil)
  }
  
  override public func loadView() {
    view = noSafeAreaNSView
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("Unavailable")
  }
  
  override public func viewDidLayout() {
    super.viewDidLayout()
    Task {
      uiProperties.updateSize(to: noSafeAreaNSView.frame.size)
      uiProperties.updateSafeAreaInsets(to: noSafeAreaNSView.realSafeAreaInsets)
    }
  }
}
#endif

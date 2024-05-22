#if os(macOS)
import SwiftUI

import HelloCore

public enum UserDraggableArea: Equatable {
  case none
  case fullWindow
  case top(points: CGFloat)
  case leading(points: CGFloat)
}

@MainActor
public protocol HelloDefaultWindow: HelloWindow {
}

class HelloNSWindow: NSWindow {
  
  var unrestrictedFrame: Bool = false
  var canBecomeKeyOverride: Bool?
  var canBecomeMainOverride: Bool?
  
  override var canBecomeKey: Bool { canBecomeKeyOverride ?? super.canBecomeKey }
  
  override var canBecomeMain: Bool { canBecomeMainOverride ?? super.canBecomeMain }
  
  var onMouseDown: ((_ point: CGPoint) -> Void)?
  var onMouseUp: (() -> Void)?
  var onMouseDragged: ((_ point: CGPoint, _ translation: CGSize) -> Void)?
  
  var draggableArea: UserDraggableArea = .fullWindow
  
  override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
    if unrestrictedFrame {
      frameRect
    } else {
      super.constrainFrameRect(frameRect, to: screen)
    }
  }
  
  override func animationResizeTime(_ newFrame: NSRect) -> TimeInterval {
    1
  }
  
  override func sendEvent(_ event: NSEvent) {
    super.sendEvent(event)
    switch event.type {
    case .leftMouseDown:
      onMouseDown?(event.locationInWindow)
      if canBecomeMain && !NSApp.isActive {
        NSApp.activate(ignoringOtherApps: true)
        makeKeyAndOrderFront(nil)
      }
      switch draggableArea {
      case .fullWindow:
        performDrag(with: event)
      case .top(let points):
        if event.locationInWindow.y > frame.size.height - points {
          performDrag(with: event)
        }
      case .leading(let points):
        if event.locationInWindow.x < points {
          performDrag(with: event)
        }
      case .none: break
      }
    case .leftMouseUp:
      onMouseUp?()
      //    case .rightMouseDown:
      //      <#code#>
      //    case .rightMouseUp:
      //      <#code#>
      //    case .mouseMoved:
      //      <#code#>
    case .leftMouseDragged:
      onMouseDragged?(event.locationInWindow, CGSize(width: event.deltaX, height: event.deltaY))
      //    case .rightMouseDragged:
      //      <#code#>
      //    case .mouseEntered:
      //      <#code#>
      //    case .mouseExited:
      //      <#code#>
      //    case .keyDown:
      //      <#code#>
      //    case .keyUp:
      //      <#code#>
    default: ()
    }
  }
}

class HelloNSPanel: NSPanel {
  
  var unrestrictedFrame: Bool = false
  var canBecomeKeyOverride: Bool?
  var canBecomeMainOverride: Bool?
  
  override func sendEvent(_ event: NSEvent) {
    super.sendEvent(event)
    switch event.type {
    case .leftMouseDown:
      NSApp.activate(ignoringOtherApps: true)
      onMouseDown?(event.locationInWindow)
      switch draggableArea {
      case .fullWindow:
        performDrag(with: event)
      case .top(let points):
        if event.locationInWindow.y > frame.size.height - points {
          performDrag(with: event)
        }
      case .leading(let points):
        if event.locationInWindow.x < points {
          performDrag(with: event)
        }
      case .none: break
      }
    case .leftMouseUp:
      onMouseUp?()
//    case .rightMouseDown:
//      <#code#>
//    case .rightMouseUp:
//      <#code#>
//    case .mouseMoved:
//      <#code#>
    case .leftMouseDragged:
      onMouseDragged?(event.locationInWindow, CGSize(width: event.deltaX, height: event.deltaY))
//    case .rightMouseDragged:
//      <#code#>
//    case .mouseEntered:
//      <#code#>
//    case .mouseExited:
//      <#code#>
//    case .keyDown:
//      <#code#>
//    case .keyUp:
//      <#code#>
    default: ()
    }
  }
  
  override var canBecomeKey: Bool { canBecomeKeyOverride ?? super.canBecomeKey }
  
  override var canBecomeMain: Bool { canBecomeMainOverride ?? super.canBecomeMain }
  
  var onMouseDown: ((_ point: CGPoint) -> Void)?
  var onMouseUp: (() -> Void)?
  var onMouseDragged: ((_ point: CGPoint, _ translation: CGSize) -> Void)?
  
  var draggableArea: UserDraggableArea = .fullWindow
  
  override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
    if unrestrictedFrame {
      frameRect
    } else {
      super.constrainFrameRect(frameRect, to: screen)
    }
  }
}

@MainActor
@Observable
public class HelloWindowModel {
  public weak var window: HelloWindow?
  public var subWindowID: String?
  
  public init() {}
  
  public func subWindowClosed() {
    if let oldSubWindowID = subWindowID {
      Task {
        try await Task.sleep(seconds: 0.2)
        guard subWindowID == oldSubWindowID else { return }
        subWindowID = nil
      }
    }
  }
  
  public func dismiss(id: String) { }
  public func dismissPopup() { }
}

@MainActor
fileprivate class HelloWindowDelegate: NSObject, NSWindowDelegate {
  
  private weak var helloWindow: HelloWindow?
  
  fileprivate init(helloWindow: HelloWindow) {
    self.helloWindow = helloWindow
  }
  
  func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
    helloWindow?.willResize(to: frameSize) ?? frameSize
  }
  
  func windowDidResize(_ notification: Notification) {
    helloWindow?.onResizeInternal()
    helloWindow?.onResize()
    helloWindow?.onFrameChanged()
  }
  
  func windowDidChangeOcclusionState(_ notification: Notification) {
    helloWindow?.onOcclusionStateChanged()
  }
  
  func windowDidMiniaturize(_ notification: Notification) {
    helloWindow?.onMinimize()
  }
  
  func windowWillMiniaturize(_ notification: Notification) {
    helloWindow?.willMinimize()
  }
  
  func windowDidDeminiaturize(_ notification: Notification) {
    helloWindow?.onDeMinimize()
  }
  func windowWillClose(_ notification: Notification) {
    helloWindow?.onCloseInternal()
    helloWindow?.onClose()
  }
  
  func windowDidMove(_ notification: Notification) {
    helloWindow?.onMove()
    helloWindow?.onFrameChanged()
  }
  
  func windowDidBecomeKey(_ notification: Notification) {
    helloWindow?.onFocus()
  }
  
  func windowDidResignKey(_ notification: Notification) {
    helloWindow?.onKeyFocusLostInternal()
    helloWindow?.onKeyFocusLost()
  }
  
  func windowDidResignMain(_ notification: Notification) {
    helloWindow?.onMainFocusLostInternal()
    helloWindow?.onMainFocusLost()
  }

  func windowDidChangeScreen(_ notification: Notification) {
    helloWindow?.onScreenChange()
  }
  
  func windowWillStartLiveResize(_ notification: Notification) {
    helloWindow?.onLiveResizeStart()
  }
  
  func windowDidEndLiveResize(_ notification: Notification) {
    helloWindow?.onLiveResizeEnd()
  }
}

@MainActor
open class HelloWindow: HelloDefaultWindow {
  
  public enum AutoCloseBehaviour {
    case onHoverLost
    case onHoverLostRespectingMouseInWindow
    case onFocusLost
    case never
  }
  
  public enum Size {
    case fixed(CGSize)
    case fixedAuto
    case resizable(frameName: String? = nil,
                   minSize: CGSize = .init(),
                   initialSize: CGSize = .init(width: 400, height: 300),
                   maxSize: CGSize = .init(width: CGFloat.infinity, height: CGFloat.infinity))
    case fullScreen
  }
  
  public static var defaultTopSafeArea: CGFloat?
  
  public let id: String
  public let uniqueID: String = UUID().uuidString
  public let nsWindow: NSWindow
  internal var onCloseSupplementary: (() -> Void)?
  var isMouseInWindow: Bool = false
  
  public let uiProperties: UIProperties
  public let windowModel: HelloWindowModel
  private let size: Size
  
  private var ref: HelloWindow?
  private var delegate: HelloWindowDelegate?
  
  public var draggableArea: UserDraggableArea {
    get { (nsWindow as? HelloNSWindow)?.draggableArea ?? (nsWindow as? HelloNSPanel)?.draggableArea ?? .none }
    set {
      (nsWindow as? HelloNSWindow)?.draggableArea = newValue
      (nsWindow as? HelloNSPanel)?.draggableArea = newValue
//      nsWindow.draggableArea = newValue
      nsWindow.isMovable = false
      nsWindow.isMovableByWindowBackground = false
    }
  }
  
  open var screen: NSScreen? { nsWindow.screen ?? .main }
  
  open var autoCloseBehaviour: AutoCloseBehaviour { .never }
  
  open var topSafeAreaOverride: CGFloat? { Self.defaultTopSafeArea }
  open var hideWindowButtons: Bool { false }
  
  public var temporaryWindowID: String? { temporaryWindow?.id }
  
  private var temporaryWindow: HelloWindow?
  public var subWindow: HelloWindow?
  private var nativeSubWindow: NSWindow?
  private weak var parentWindow: HelloWindow?
  
  public init<Content: View>(view: Content,
                             id: String = UUID().uuidString,
                             parentWindow: HelloWindow? = nil,
                             size: Size = .resizable(initialSize: CGSize(width: 400, height: 300)),
                             windowFlags: NSWindow.StyleMask = [.closable, .titled, .fullSizeContentView],
                             forceKey: Bool? = nil,
                             canBecomeMainOverride: Bool? = nil,
                             isPanel: Bool = false,
                             unrestrictedFrame: Bool = false) {
    self.id = id
    self.parentWindow = parentWindow
    var initialSize: CGSize
    switch size {
    case .fixed(let size):
      initialSize = size
    case .fixedAuto:
      initialSize = .zero
    case .resizable(_, _, let size, _):
      initialSize = size
    case .fullScreen:
      initialSize = NSScreen.main?.frame.size ?? .zero
    }
    self.size = size
    uiProperties = UIProperties()
    if isPanel {
      let panel = HelloNSPanel(contentRect: CGRect(origin: .zero, size: initialSize),
                         styleMask: windowFlags,
                         backing: .buffered,
                         defer: true)
//      panel.
//      print(panel.ignoresMouseEvents)
      panel.styleMask.insert(.nonactivatingPanel)
      panel.hidesOnDeactivate = false
      nsWindow = panel
    } else {
      nsWindow = HelloNSWindow(contentRect: CGRect(origin: .zero, size: initialSize),
                            styleMask: windowFlags,
                            backing: .buffered, 
                            defer: true)
    }
    windowModel = HelloWindowModel()
    (nsWindow as? HelloNSWindow)?.unrestrictedFrame = unrestrictedFrame
    (nsWindow as? HelloNSWindow)?.canBecomeKeyOverride = forceKey
    (nsWindow as? HelloNSWindow)?.canBecomeMainOverride = canBecomeMainOverride ?? forceKey
    (nsWindow as? HelloNSPanel)?.unrestrictedFrame = unrestrictedFrame
    (nsWindow as? HelloNSPanel)?.canBecomeKeyOverride = forceKey
    (nsWindow as? HelloNSPanel)?.canBecomeMainOverride = canBecomeMainOverride ?? forceKey
    
    nsWindow.titlebarAppearsTransparent = true
    nsWindow.titlebarSeparatorStyle = .none
    nsWindow.title = ""
    nsWindow.titleVisibility = .hidden
    nsWindow.preventsApplicationTerminationWhenModal = false
    nsWindow.isMovable = true
    nsWindow.isMovableByWindowBackground = true
    nsWindow.isReleasedWhenClosed = false
    delegate = HelloWindowDelegate(helloWindow: self)
    nsWindow.delegate = delegate
    
    windowModel.window = self
    
    if case .resizable(let frameName, _, _, _) = size {
      nsWindow.styleMask.insert(.resizable)
      if let frameName {
        _ = nsWindow.setFrameAutosaveName(frameName)
        initialSize = nsWindow.frame.size
      }
    }
    uiProperties.updateSize(to: initialSize)
    uiProperties.updateSafeAreaInsets(to: nsWindow.contentView?.safeAreaInsets ?? NSEdgeInsets())
    switch size {
    case .fixed(let size):
      let rootViewController = HelloRootViewController(rootView: view.frame(size).environment(windowModel), uiProperties: uiProperties)
      rootViewController.onMouseEntered = { [weak self] in self?.onMouseEnteredInternal() }
      rootViewController.onMouseExited = { [weak self] in self?.onMouseExitedInternal() }
      rootViewController.onMouseMoved = { [weak self] point in self?.onMouseMoved(to: point) }
      rootViewController.onCursorUpdate = { [weak self] in self?.onCursorUpdate() }
      nsWindow.contentViewController = rootViewController
      nsWindow.contentMinSize = size
      nsWindow.minSize = size
      nsWindow.contentMaxSize = size
      nsWindow.maxSize = size
    case .fixedAuto:
      let rootViewController = HelloRootViewController(rootView: view.environment(windowModel), uiProperties: uiProperties)
      rootViewController.onMouseEntered = { [weak self] in self?.onMouseEnteredInternal() }
      rootViewController.onMouseExited = { [weak self] in self?.onMouseExitedInternal() }
      rootViewController.onMouseMoved = { [weak self] point in self?.onMouseMoved(to: point) }
      rootViewController.onCursorUpdate = { [weak self] in self?.onCursorUpdate() }
      nsWindow.contentViewController = rootViewController
    case .resizable(_, let minSize, _, let maxSize):
      let rootViewController = HelloRootViewController(rootView: view.frame(minSize: minSize, maxSize: maxSize, alignment: .top).environment(windowModel), uiProperties: uiProperties)
      rootViewController.onMouseEntered = { [weak self] in self?.onMouseEnteredInternal() }
      rootViewController.onMouseExited = { [weak self] in self?.onMouseExitedInternal() }
      rootViewController.onMouseMoved = { [weak self] point in self?.onMouseMoved(to: point) }
      rootViewController.onCursorUpdate = { [weak self] in self?.onCursorUpdate() }
      nsWindow.contentViewController = rootViewController
      nsWindow.contentMinSize = minSize
      nsWindow.minSize = minSize
      nsWindow.contentMaxSize = maxSize
      nsWindow.maxSize = maxSize
    case .fullScreen:
      draggableArea = .none
      let rootViewController = HelloRootViewController(rootView: view.environment(windowModel), uiProperties: uiProperties)
      rootViewController.onMouseEntered = { [weak self] in self?.onMouseEnteredInternal() }
      rootViewController.onMouseExited = { [weak self] in self?.onMouseExitedInternal() }
      rootViewController.onMouseMoved = { [weak self] point in self?.onMouseMoved(to: point) }
      rootViewController.onCursorUpdate = { [weak self] in self?.onCursorUpdate() }
      nsWindow.contentViewController = rootViewController
//      for _ in NotificationCenter.default.notifications(named: NSApplication.didChangeScreenParametersNotification) {
//
//      }
      NotificationCenter.default.addObserver(
        forName: NSApplication.didChangeScreenParametersNotification,
        object: NSApplication.shared,
        queue: .main
      ) { [weak self] notification -> Void in
        guard let self else { return }
        Task { await self.matchFullScreenSize() }
      }
      matchFullScreenSize()
    }
    (nsWindow as? HelloNSWindow)?.onMouseDown = { [weak self] in self?.onMouseDown(at: $0) }
    (nsWindow as? HelloNSWindow)?.onMouseUp = { [weak self] in self?.onMouseUp() }
    (nsWindow as? HelloNSWindow)?.onMouseDragged = { [weak self] in self?.onMouseDragged(at: $0, by: $1) }
    (nsWindow as? HelloNSPanel)?.onMouseDown = { [weak self] in self?.onMouseDown(at: $0) }
    (nsWindow as? HelloNSPanel)?.onMouseUp = { [weak self] in self?.onMouseUp() }
    (nsWindow as? HelloNSPanel)?.onMouseDragged = { [weak self] in self?.onMouseDragged(at: $0, by: $1) }
    updateControlButtons()
    ref = self
  }
    
  open func onMouseDown(at point: CGPoint) {}
  open func onMouseUp() {}
  open func onMouseDragged(at point: CGPoint, by translation: CGSize) {}
  open func onMouseEntered() {}
  open func onMouseExited() {}
  open func onMouseMoved(to point: CGPoint) {}
  open func onCursorUpdate() {}
  
  open func onClose() {}
  open func onFocus() {}
  open func onKeyFocusLost() {}
  open func onMainFocusLost() {}
  open func onResize() {}
  open func willResize(to targetSize: NSSize) -> NSSize { targetSize }
  open func onMove() {}
  open func onFrameChanged() {}
  open func onScreenChange() {}
  open func onLiveResizeStart() {}
  open func onLiveResizeEnd() {}
  open func onMinimize() {}
  open func willMinimize() {}
  open func onDeMinimize() {}
  open func onOcclusionStateChanged() {}
  
  fileprivate func onMouseEnteredInternal() {
    isMouseInWindow = true
    onMouseEntered()
  }
  
  fileprivate func onMouseExitedInternal() {
    isMouseInWindow = false
    closeTemporaryWindow()
    if autoCloseBehaviour == .onHoverLost || autoCloseBehaviour == .onHoverLostRespectingMouseInWindow {
      close()
    }
    onMouseExited()
  }
  
  fileprivate func onKeyFocusLostInternal() {
    closeTemporaryWindow()
    if autoCloseBehaviour == .onFocusLost && subWindow == nil && nativeSubWindow == nil && !nsWindow.isMainWindow {
      close()
    }
  }
  
  fileprivate func onMainFocusLostInternal() {
    closeTemporaryWindow()
    if autoCloseBehaviour == .onFocusLost && subWindow == nil && nativeSubWindow == nil {
      close()
    }
  }
  
  fileprivate func onCloseInternal() {
    closeTemporaryWindow()
    closeSubWindow()
    onCloseSupplementary?()
    onCloseSupplementary = nil
    ref = nil
    let wasFocused = nsWindow.isKeyWindow
    Task {
      parentWindow?.subWindowClosed(wasFocused: wasFocused)
      parentWindow = nil
    }
  }
  
  fileprivate func onResizeInternal() {
    updateControlButtons()
  }
  
  public var buttonSize: CGFloat { nsWindow.standardWindowButton(.closeButton)?.frame.size.width ?? 8 }
  
  public var frame: CGRect { nsWindow.frame }
  
  public var frameInScreen: CGRect {
    var frame = nsWindow.frame
    frame.origin -= (nsWindow.screen?.frame.origin ?? .zero)
    return frame
  }
  
  open func show() {
    switch size {
    case .fullScreen:
      matchFullScreenSize()
    case .resizable(let frameName, _, let initialSize, _):
      let userResized = frameName != nil && nsWindow.frame.size != initialSize
      if !userResized && !nsWindow.isVisible {
        nsWindow.center()
      }
    default:
      if !nsWindow.isVisible {
        nsWindow.center()
      }
    }
    if nsWindow.canBecomeKey {
      nsWindow.makeKeyAndOrderFront(self)
    } else {
      nsWindow.orderFrontRegardless()
    }
  }
  
  public func subWindowClosed(wasFocused: Bool) {
    subWindow = nil
    windowModel.subWindowClosed()
    if wasFocused && nsWindow.isVisible {
      nsWindow.makeKeyAndOrderFront(nil)
    } else if !nsWindow.isKeyWindow && autoCloseBehaviour == .onFocusLost {
      close()
    }
  }
  
  public func bringToFront() {
    nsWindow.orderFrontRegardless()
  }
  
  open func close() {
    nsWindow.contentViewController?.view.removeFromSuperview()
    nsWindow.close()
  }
  
  public func show(temporaryWindow: HelloWindow) {
    closeTemporaryWindow()
    self.temporaryWindow = temporaryWindow
    temporaryWindow.show()
  }
  
  public func closeTemporaryWindow() {
    guard let temporaryWindow else { return }
    self.temporaryWindow = nil
    temporaryWindow.close()
  }
  
  public func show(subWindow: HelloWindow) {
    self.subWindow?.parentWindow = nil
    closeSubWindow()
    subWindow.parentWindow = self
    self.subWindow = subWindow
    subWindow.show()
    windowModel.subWindowID = subWindow.id
  }
  
  public func show(nativeSubWindow: NSWindow) {
    closeSubWindow()
    self.nativeSubWindow = nativeSubWindow
    nativeSubWindow.makeKeyAndOrderFront(self)
  }
  
  public func show(subView: some View, at point: CGPoint, alignment: Alignment, id: String = UUID().uuidString, autoCloseBehaviour: HelloWindow.AutoCloseBehaviour = .onFocusLost) {
    show(subWindow: HelloSubWindow(id: id,
                                   anchor: .init(point: point, alignment: alignment),
                                   autoCloseBehaviour: autoCloseBehaviour,
                                   parentWindow: self,
                                   windowLevel: nsWindow.level,
                                   content: subView))
  }
  
  public func show(temporarySubView: some View, at point: CGPoint, alignment: Alignment, id: String = UUID().uuidString, autoCloseBehaviour: HelloWindow.AutoCloseBehaviour = .onHoverLost) {
    show(temporaryWindow: HelloSubWindow(id: id,
                                         anchor: .init(point: point, alignment: alignment),
                                         autoCloseBehaviour: autoCloseBehaviour,
                                         parentWindow: nil,
                                         windowLevel: nsWindow.level,
                                         content: temporarySubView,
                                         canBecomeMain: false,
                                         canBecomeKey: false))
  }
  
  public func closeSubWindow() {
    guard let subWindow else { return }
    self.subWindow = nil
    subWindow.close()
    windowModel.subWindowClosed()
  }
  
  public func closeIfNeeded(windowID: String) {
    guard let subWindow = subWindow, subWindow.id == windowID else { return }
    switch subWindow.autoCloseBehaviour {
    case .onFocusLost:
      closeSubWindow()
    case .onHoverLostRespectingMouseInWindow:
      Task {
        try await Task.sleep(seconds: 0.1)
        guard self.subWindow?.uniqueID == subWindow.uniqueID && subWindow.id == windowID && !subWindow.isMouseInWindow else { return }
        closeSubWindow()
      }
    default: ()
    }
  }
  
  public func matchFullScreenSize() {
    guard let screenFrame = screen?.frame else { return }
    guard let safeAreaFrame = screen?.visibleFrame else { return }
    let diff = screenFrame - safeAreaFrame
//    uiProperties.updateSize(to: screenFrame.size)
    nsWindow.setFrame(screenFrame, display: false, animate: false)
    uiProperties.updateSafeAreaInsets(to: .init(top: abs(diff.size.height - diff.origin.y),
                                                left: diff.origin.x,
                                                bottom: diff.origin.y,
                                                right: (diff.size.width - diff.origin.x)))
  }
  
  public func updateControlButtons() {
    nsWindow.standardWindowButton(.closeButton)?.isHidden = hideWindowButtons
    nsWindow.standardWindowButton(.miniaturizeButton)?.isHidden = hideWindowButtons
    nsWindow.standardWindowButton(.zoomButton)?.isHidden = hideWindowButtons
    if hideWindowButtons {
      uiProperties.updateSafeAreaInsets(to: .init())
    } else if !hideWindowButtons {
      let heightOffset = nsWindow.standardWindowButton(.closeButton)?.superview?.frame.height ?? 0
      defer {
        uiProperties.updateSafeAreaInsets(to: NativeEdgeInsets(top: topSafeAreaOverride ?? heightOffset,
                                                               left: 0, bottom: 0, right: 0))
      }
      guard let closeButtonFrame = nsWindow.standardWindowButton(.closeButton)?.frame else { return }
      guard let topSafeAreaOverride else { return }
      let buttonYPosition: CGFloat = -0.5 * topSafeAreaOverride - 0.5 * closeButtonFrame.height + heightOffset
      guard nsWindow.standardWindowButton(.closeButton)?.frame.origin.y != buttonYPosition else { return }
      nsWindow.standardWindowButton(.closeButton)?.frame.origin.y = buttonYPosition
      nsWindow.standardWindowButton(.miniaturizeButton)?.frame.origin.y = buttonYPosition
      nsWindow.standardWindowButton(.zoomButton)?.frame.origin.y = buttonYPosition
      
      nsWindow.standardWindowButton(.closeButton)?.frame.origin.x = 0.5 * topSafeAreaOverride - 0.5 * closeButtonFrame.width
      nsWindow.standardWindowButton(.miniaturizeButton)?.frame.origin.x = 0.5 * topSafeAreaOverride - 0.5 * closeButtonFrame.width + 1 * 1.5 * closeButtonFrame.width
      nsWindow.standardWindowButton(.zoomButton)?.frame.origin.x = 0.5 * topSafeAreaOverride - 0.5 * closeButtonFrame.width + 2 * 1.5 * closeButtonFrame.width
    }
  }
}
#endif

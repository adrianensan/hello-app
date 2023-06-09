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
protocol OFDefaultWindow: OFWindow {
  
}

extension OFDefaultWindow {
  func close() {
    nsWindow.close()
  }
}

class OFNSWindow: NSWindow {
  
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
      return frameRect
    } else {
      return super.constrainFrameRect(frameRect, to: screen)
    }
  }
  
  override func mouseDragged(with event: NSEvent) {
    super.mouseDragged(with: event)
    onMouseDragged?(event.locationInWindow, CGSize(width: event.deltaX, height: event.deltaY))
  }
  
  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
    if canBecomeMain && !NSApp.isActive {
      NSApp.activate(ignoringOtherApps: true)
      makeKeyAndOrderFront(nil)
    }
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
  }
  
  override func mouseUp(with event: NSEvent) {
    super.mouseUp(with: event)
    onMouseUp?()
  }
}

@MainActor
public class OFWindowModel: ObservableObject {
  public weak var window: OFWindow?
  public var subWindowID: String?
  
  public func subWindowClosed() {
    if let oldSubWindowID = subWindowID {
      Task {
        try await Task.sleep(seconds: 0.2)
        guard subWindowID == oldSubWindowID else { return }
        subWindowID = nil
      }
    }
  }
}

@MainActor
fileprivate class OFWindowDelegate: NSObject, NSWindowDelegate {
  
  private weak var ofWindow: OFWindow?
  
  fileprivate init(ofWindow: OFWindow) {
    self.ofWindow = ofWindow
  }
  
  func windowDidResize(_ notification: Notification) {
    ofWindow?.onResizeInternal()
    ofWindow?.onResize()
    ofWindow?.onFrameChanged()
  }
  
  func windowWillClose(_ notification: Notification) {
    ofWindow?.onCloseInternal()
    ofWindow?.onClose()
  }
  
  func windowDidMove(_ notification: Notification) {
    ofWindow?.onMove()
    ofWindow?.onFrameChanged()
  }
  
  func windowDidBecomeKey(_ notification: Notification) {
    ofWindow?.onFocus()
  }
  
  func windowDidResignKey(_ notification: Notification) {
    ofWindow?.onKeyFocusLostInternal()
    ofWindow?.onKeyFocusLost()
  }
  
  func windowDidResignMain(_ notification: Notification) {
    ofWindow?.onMainFocusLostInternal()
    ofWindow?.onMainFocusLost()
  }
  
  func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
    ofWindow?.willResize(to: frameSize) ?? frameSize
  }

  func windowDidChangeScreen(_ notification: Notification) {
    ofWindow?.onScreenChange()
  }
  
  func windowWillStartLiveResize(_ notification: Notification) {
    ofWindow?.onLiveResizeStart()
  }
  
  func windowDidEndLiveResize(_ notification: Notification) {
    ofWindow?.onLiveResizeEnd()
  }
}

@MainActor
open class OFWindow: OFDefaultWindow {
  
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
  
  public let id: String
  public let uniqueID: String = UUID().uuidString
  public let nsWindow: NSWindow
  var onCloseExtra: (() -> Void)?
  var isMouseInWindow: Bool = false
  
  public let uiProperties: UIProperties
  public let windowModel: OFWindowModel
  private let size: Size
  
  private var ref: OFWindow?
  private var delegate: OFWindowDelegate?
  
  public var draggableArea: UserDraggableArea {
    get { (nsWindow as? OFNSWindow)?.draggableArea ?? .none }
    set {
      (nsWindow as? OFNSWindow)?.draggableArea = newValue
//      nsWindow.draggableArea = newValue
      nsWindow.isMovable = false
      nsWindow.isMovableByWindowBackground = false
    }
  }
  
  open var screen: NSScreen? { nsWindow.screen ?? .main }
  
  open var autoCloseBehaviour: AutoCloseBehaviour { .never }
  
  open var extraTopSafeArea: CGFloat { 0 }
  open var hideWindowButtons: Bool { false }
  
  private var temporaryWindow: OFWindow?
  public var subWindow: OFWindow?
  private var nativeSubWindow: NSWindow?
  private weak var parentWindow: OFWindow?
  private var expectedCloseButtonY: CGFloat?
  
  public init<Content: View>(view: Content,
                      id: String = UUID().uuidString,
                      parentWindow: OFWindow? = nil,
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
      let panel = NSPanel(contentRect: CGRect(origin: .zero, size: initialSize),
                         styleMask: [.borderless, .nonactivatingPanel],
                         backing: .buffered,
                         defer: true)
      panel.isFloatingPanel = true
      panel.hidesOnDeactivate = false
      nsWindow = panel
    } else {
      nsWindow = OFNSWindow(contentRect: CGRect(origin: .zero, size: initialSize),
                            styleMask: windowFlags,
                            backing: .buffered, defer: true)
    }
    windowModel = OFWindowModel()
    (nsWindow as? OFNSWindow)?.unrestrictedFrame = unrestrictedFrame
    (nsWindow as? OFNSWindow)?.canBecomeKeyOverride = forceKey
    (nsWindow as? OFNSWindow)?.canBecomeMainOverride = canBecomeMainOverride ?? forceKey

    uiProperties.extraSafeArea = extraTopSafeArea
    
    nsWindow.titlebarAppearsTransparent = true
    nsWindow.titlebarSeparatorStyle = .none
    nsWindow.title = ""
    nsWindow.titleVisibility = .hidden
    nsWindow.preventsApplicationTerminationWhenModal = false
    nsWindow.isMovable = true
    nsWindow.isMovableByWindowBackground = true
    nsWindow.isReleasedWhenClosed = false
    delegate = OFWindowDelegate(ofWindow: self)
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
      let rootViewController = OFRootViewController(rootView: view.frame(size).environmentObject(windowModel), uiProperties: uiProperties)
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
      let rootViewController = OFRootViewController(rootView: view.environmentObject(windowModel), uiProperties: uiProperties)
      rootViewController.onMouseEntered = { [weak self] in self?.onMouseEnteredInternal() }
      rootViewController.onMouseExited = { [weak self] in self?.onMouseExitedInternal() }
      rootViewController.onMouseMoved = { [weak self] point in self?.onMouseMoved(to: point) }
      rootViewController.onCursorUpdate = { [weak self] in self?.onCursorUpdate() }
      nsWindow.contentViewController = rootViewController
    case .resizable(_, let minSize, _, let maxSize):
      let rootViewController = OFRootViewController(rootView: view.frame(minSize: minSize, maxSize: maxSize, alignment: .top).environmentObject(windowModel), uiProperties: uiProperties)
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
      let rootViewController = OFRootViewController(rootView: view.environmentObject(windowModel), uiProperties: uiProperties)
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
    (nsWindow as? OFNSWindow)?.onMouseDown = { [weak self] in self?.onMouseDown(at: $0) }
    (nsWindow as? OFNSWindow)?.onMouseUp = { [weak self] in self?.onMouseUp() }
    (nsWindow as? OFNSWindow)?.onMouseDragged = { [weak self] in self?.onMouseDragged(at: $0, by: $1) }
    updateControlButtons()
    if hideWindowButtons {
      nsWindow.standardWindowButton(.closeButton)?.isHidden = true
      nsWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
      nsWindow.standardWindowButton(.zoomButton)?.isHidden = true
    }
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
    onCloseExtra?()
    onCloseExtra = nil
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
  
  public func show(temporaryWindow: OFWindow) {
    closeTemporaryWindow()
    self.temporaryWindow = temporaryWindow
    temporaryWindow.show()
  }
  
  public func closeTemporaryWindow() {
    guard let temporaryWindow else { return }
    self.temporaryWindow = nil
    temporaryWindow.close()
  }
  
  public func show(subWindow: OFWindow) {
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
  
  public func show(subView: some View, at point: CGPoint, alignment: Alignment, id: String = UUID().uuidString, autoCloseBehaviour: OFWindow.AutoCloseBehaviour = .onFocusLost) {
    show(subWindow: HelloSubWindow(id: id,
                                   anchor: .init(point: point, alignment: alignment),
                                   autoCloseBehaviour: autoCloseBehaviour,
                                   parentWindow: self,
                                   windowLevel: nsWindow.level,
                                   content: subView))
  }
  
  public func show(temporarySubView: some View, at point: CGPoint, alignment: Alignment, id: String = UUID().uuidString, autoCloseBehaviour: OFWindow.AutoCloseBehaviour = .onFocusLost) {
    show(temporaryWindow: HelloSubWindow(id: id,
                                   anchor: .init(point: point, alignment: alignment),
                                   autoCloseBehaviour: autoCloseBehaviour,
                                   parentWindow: self,
                                   windowLevel: nsWindow.level,
                                   content: temporarySubView))
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
  
  func updateControlButtons() {
    guard extraTopSafeArea > 0 else { return }
    let current = (nsWindow.standardWindowButton(.closeButton)?.frame.origin.y ?? 0)
    if let expectedCloseButtonY {
      guard expectedCloseButtonY < current else { return }
    }
    expectedCloseButtonY = current - 0.5 * extraTopSafeArea
    nsWindow.standardWindowButton(.closeButton)?.frame.origin += CGPoint(x: 0.5 * extraTopSafeArea,
                                                                         y: -0.5 * extraTopSafeArea)
    nsWindow.standardWindowButton(.miniaturizeButton)?.frame.origin += CGPoint(x: 0.5 * extraTopSafeArea,
                                                                               y: -0.5 * extraTopSafeArea)
    nsWindow.standardWindowButton(.zoomButton)?.frame.origin += CGPoint(x: 0.5 * extraTopSafeArea,
                                                                        y: -0.5 * extraTopSafeArea)
  }
}
#endif

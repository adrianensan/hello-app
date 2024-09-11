import SwiftUI
import Observation

import HelloCore

#if os(iOS)
@MainActor
public func globalDismissKeyboard() {
  UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
#else
public func globalDismissKeyboard() {
  
}
#endif

#if !os(macOS)

public struct HelloSheetConfig<Content: View> {
  var id: String
  var dragToDismissType: GestureType = .highPriority
  var view: @MainActor () -> Content
  
  public init(id: String,
              dragToDismissType: GestureType = .highPriority,
              view: @escaping @MainActor () -> Content) {
    self.id = id
    self.dragToDismissType = dragToDismissType
    self.view = view
  }
}

@MainActor
@Observable
public class HelloWindowModel {
  
  #if os(iOS) || os(tvOS) || os(visionOS)
  public weak var window: UIWindow?
  #endif
  
  struct PopupWindow: Identifiable, Sendable {
    var id: String
    var uniqueInstanceID: String
    var hasExclusiveInteraction: Bool
    var view: @MainActor () -> AnyView
    var onDismiss: (@MainActor () -> Void)?
    
    init(viewID: String,
         hasExclusiveInteraction: Bool = true,
         view: @escaping @MainActor () -> some View,
         onDismiss: (@MainActor () -> Void)? = nil) {
      self.uniqueInstanceID = .uuid
      self.id = viewID
      self.hasExclusiveInteraction = hasExclusiveInteraction
      self.view = { AnyView(view()) }
      self.onDismiss = onDismiss
    }
  }
  
  var blurAmountForPopup: CGFloat = 0
  var isShowingConfetti: Bool = false
  var freeze: Bool = false
  var confettiID: String = .uuid
  var popupViews: [PopupWindow] = []
  
  public func showPopup<Content: View>(blurBackground: Bool = false,
                                       onDismiss: (@MainActor () -> Void)? = nil,
                                       _ view: @escaping @MainActor () -> Content) {
    blurAmountForPopup = blurBackground ? 16 : 0
    popupViews.append(PopupWindow(viewID: String(describing: Content.self), view: view, onDismiss: onDismiss))
  }
  
  public func show(alert alertConfig: HelloAlertConfig) {
    blurAmountForPopup = 0
    globalDismissKeyboard()
    popupViews.append(PopupWindow(viewID: alertConfig.id) { HelloAlert(config: alertConfig) })
  }
  
  #if os(iOS)
  public func presentSheet<Content: View>(
    dragToDismissType: GestureType = .highPriority,
    sheet: @MainActor @escaping () -> Content) {
      present(sheet: HelloSheetConfig(id: String(describing: Content.self), dragToDismissType: dragToDismissType, view: sheet))
    }
  
  public func present(sheet: HelloSheetConfig<some View>) {
    present(id: sheet.id) { HelloSheet(dragToDismissType: sheet.dragToDismissType, content: sheet.view) }
  }
  #endif
  
  public func present<Content: View>(
    id: String = String(describing: Content.self),
    hasExclusiveInteraction: Bool = true,
    view: @MainActor @escaping () -> Content) {
      guard !popupViews.contains(where: { $0.id == id }) else {
        Log.warning("Trying to present duplicate view")
        return
      }
      globalDismissKeyboard()
      blurAmountForPopup = 0
      popupViews.append(PopupWindow(viewID: id, hasExclusiveInteraction: hasExclusiveInteraction, view: view))
  }
  
  public func dismissPopup() {
    guard !popupViews.isEmpty else { return }
    popupViews.last?.onDismiss?()
    popupViews.popLast()
  }
  
  public func dismiss(id: String?) {
    guard !popupViews.isEmpty else { return }
    popupViews
      .filter { $0.id == id }
      .forEach { $0.onDismiss?() }
    popupViews = popupViews.filter { $0.id != id }
  }
  
  public func dismiss(above targetID: String) {
    guard !popupViews.isEmpty else { return }
    while popupViews.last?.id != nil && popupViews.last?.id != targetID {
      popupViews.popLast()
    }
  }
  
  public func isPresenting(_ id: String) -> Bool {
    popupViews.contains { $0.id == id }
  }
  
  public func dismissAllPopups() {
    guard !popupViews.isEmpty else { return }
    popupViews.forEach { $0.onDismiss?() }
    popupViews = []
  }
  
  public func showConfetti() {
    confettiID = .uuid
    isShowingConfetti = true
  }
  
  public func stopConfetti() {
    isShowingConfetti = false
  }
}
#endif

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

@MainActor
@Observable
public class HelloWindowModel {
  
  #if os(iOS) || os(tvOS) || os(visionOS)
  public weak var window: UIWindow?
  #endif
  
  struct PopupWindow: Identifiable, Sendable {
    var id: String
    var uniqueInstanceID: String
    var view: @MainActor () -> AnyView
    var onDismiss: (@MainActor () -> Void)?
    
    init(viewID: String,
         view: @escaping @MainActor () -> some View,
         onDismiss: (@MainActor () -> Void)? = nil) {
      self.uniqueInstanceID = .uuid
      self.id = viewID
      self.view = { AnyView(view()) }
      self.onDismiss = onDismiss
    }
  }
  
  var blurBackgroundForPopup: Bool = true
  var popupViews: [PopupWindow] = []
  
  public func showPopup<Content: View>(blurBackground: Bool = false,
                                       onDismiss: (@MainActor () -> Void)? = nil,
                                       _ view: @escaping @MainActor () -> Content) {
    blurBackgroundForPopup = blurBackground
    popupViews.append(PopupWindow(viewID: String(describing: Content.self), view: view, onDismiss: onDismiss))
  }
  
  public func show(alert alertConfig: HelloAlertConfig) {
    blurBackgroundForPopup = true
    globalDismissKeyboard()
    popupViews.append(PopupWindow(viewID: alertConfig.id) { HelloAlert(config: alertConfig) })
  }
  
  #if os(iOS)
  public func presentSheet<Content: View>(
    id: String = String(describing: Content.self),
    dragToDismissType: GestureType = .highPriority,
    sheet: @MainActor @escaping () -> Content) {
      present(id: id) { HelloSheet(dragToDismissType: dragToDismissType, content: sheet) }
    }
  #endif
  
  public func present<Content: View>(
    id: String = String(describing: Content.self),
    view: @MainActor @escaping () -> Content) {
      guard !popupViews.contains(where: { $0.id == id }) else {
        Log.warning("Trying to present duplicate view")
        return
      }
      blurBackgroundForPopup = false
      globalDismissKeyboard()
      popupViews.append(PopupWindow(viewID: id, view: view))
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
}
#endif

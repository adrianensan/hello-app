import SwiftUI
import Observation

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
    var viewID: String
    var instanceID: String
    var view: @MainActor () -> AnyView
    var onDismiss: (@MainActor () -> Void)?
    
    var id: String { instanceID }
    
    init(instanceID: String = UUID().uuidString,
         viewID: String,
         view: @escaping @MainActor () -> some View,
         onDismiss: (@MainActor () -> Void)? = nil) {
      self.instanceID = instanceID
      self.viewID = viewID
      self.view = { 
        AnyView(view()
          .id(instanceID)
          .environment(\.viewID, viewID))
      }
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
  public func present<Content: View>(
    id: String = String(describing: Content.self),
    dragToDismissType: GestureType = .highPriority,
    sheet: @MainActor @escaping () -> Content) {
      guard !popupViews.contains(where: { $0.viewID == id }) else { return }
      blurBackgroundForPopup = false
      globalDismissKeyboard()
      popupViews.append(PopupWindow(viewID: id) { HelloSheet(id: id, dragToDismissType: dragToDismissType, content: sheet) })
    }
#endif
  
  public func present(view: @MainActor @autoclosure @escaping () -> some View) {
    blurBackgroundForPopup = false
    globalDismissKeyboard()
    popupViews.append(PopupWindow(viewID: String(describing: view.self)) { view() })
  }
  
  public func dismissPopup() {
    guard !popupViews.isEmpty else { return }
    popupViews.last?.onDismiss?()
    popupViews.popLast()
  }
  
  public func dismiss(id: String) {
    guard !popupViews.isEmpty else { return }
    popupViews
      .filter { $0.viewID == id }
      .forEach { $0.onDismiss?() }
    popupViews = popupViews.filter { $0.viewID != id }
  }
  
  public func dismissAllPopups() {
    guard !popupViews.isEmpty else { return }
    popupViews.forEach { $0.onDismiss?() }
    popupViews = []
  }
}
#endif

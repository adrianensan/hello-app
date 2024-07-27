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
    
    var id: String { instanceID }
    
    init(instanceID: String = UUID().uuidString, viewID: String, view: @escaping @MainActor () -> some View) {
      self.instanceID = instanceID
      self.viewID = viewID
      self.view = { 
        AnyView(view()
          .id(instanceID)
          .environment(\.viewID, viewID))
      }
    }
  }
  
  var blurBackgroundForPopup: Bool = true
  var popupViews: [PopupWindow] = []
  
  public func showPopup<Content: View>(blurBackground: Bool = true, _ view: Content) {
    blurBackgroundForPopup = blurBackground
    popupViews.append(PopupWindow(viewID: String(describing: Content.self)) { view })
  }
  
  public func dismissPopup() {
    guard !popupViews.isEmpty else { return }
    popupViews.popLast()
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
  
  public func dismiss(id: String) {
    guard !popupViews.isEmpty else { return }
    popupViews = popupViews.filter { $0.viewID != id }
  }
  
  public func dismissAllPopups() {
    guard !popupViews.isEmpty else { return }
    popupViews = []
  }
}
#endif

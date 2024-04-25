import SwiftUI
import Observation

#if os(iOS)
public func globalDismissKeyboard() {
  UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
#else
public func globalDismissKeyboard() {
  
}
#endif

@MainActor
@Observable
public class HelloWindowModel {
  
  #if os(iOS) || os(tvOS) || os(visionOS)
  public weak var window: UIWindow?
  #endif
  
  struct PopupWindow: Identifiable, Sendable {
    var viewID: String
    var instanceID: String
    var view: () -> AnyView
    
    var id: String { instanceID }
    
    init(instanceID: String = UUID().uuidString, viewID: String, view: @escaping () -> some View) {
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
  
  public func present(id: String = UUID().uuidString,
                      dragToDismissType: GestureType = .highPriority,
                      sheet: @MainActor @autoclosure @escaping () -> some View) {
    guard !popupViews.contains(where: { $0.viewID == id }) else { return }
    blurBackgroundForPopup = false
    globalDismissKeyboard()
    popupViews.append(PopupWindow(viewID: id) { HelloSheet(id: id, dragToDismissType: dragToDismissType, content: sheet) })
  }
  
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

private struct ViewIDEnvironmentKey: EnvironmentKey {
  static let defaultValue: String? = nil
}

public extension EnvironmentValues {
  var viewID: String? {
    get { self[ViewIDEnvironmentKey.self] }
    set { self[ViewIDEnvironmentKey.self] = newValue }
  }
}

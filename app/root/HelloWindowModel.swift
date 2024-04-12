import SwiftUI
import Observation

public func globalDismissKeyboard() {
  UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

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
    
    init(viewID: String, view: @escaping () -> some View) {
      self.viewID = viewID
      self.instanceID = UUID().uuidString
      self.view = { AnyView(view()) }
    }
  }
  
  var blurBackgroundForPopup: Bool = true
  var popupViews: [PopupWindow] = []
  
  public func showPopup<Content: View>(blurBackground: Bool = true, _ view: Content) {
    blurBackgroundForPopup = blurBackground
    popupViews.append(PopupWindow(viewID: String(describing: Content.self)) { view.id(UUID().uuidString) })
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
                      sheet: @MainActor @autoclosure @escaping () -> some View) {
    guard !popupViews.contains(where: { $0.viewID == id }) else { return }
    blurBackgroundForPopup = false
    globalDismissKeyboard()
    popupViews.append(PopupWindow(viewID: id) { HelloSheet(id: id, content: sheet) })
  }
  
  public func present(view: @MainActor @autoclosure @escaping () -> some View) {
    blurBackgroundForPopup = false
    globalDismissKeyboard()
    popupViews.append(PopupWindow(viewID: String(describing: view.self)) { view() })
  }
  
  public func dismissSheet() {
    guard !popupViews.isEmpty else { return }
    popupViews.popLast()
  }
  
  public func dismissSheet(id: String) {
    guard !popupViews.isEmpty else { return }
    popupViews = popupViews.filter { $0.viewID != id }
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

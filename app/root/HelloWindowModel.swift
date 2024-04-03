import SwiftUI
import Observation

@MainActor
@Observable
public class HelloWindowModel {
  
  #if os(iOS) || os(tvOS) || os(visionOS)
  public weak var window: UIWindow?
  #endif
  
  struct PopupWindow: Identifiable, Sendable {
    var id: String
    var view: () -> AnyView
    
    init(id: String = UUID().uuidString, view: @escaping () -> some View) {
      self.id = id
      self.view = { AnyView(view()) }
    }
  }
  
  var blurBackgroundForPopup: Bool = true
  var popupViews: [PopupWindow] = []
  var alertView: HelloAlert?
  
  var alertViewID: String = UUID().uuidString
  
  public func showPopup<Content: View>(blurBackground: Bool = true, _ view: Content) {
    blurBackgroundForPopup = blurBackground
    popupViews.append(PopupWindow { view.id(UUID().uuidString) })
  }
  
  public func dismissPopup() {
    guard !popupViews.isEmpty else { return }
    popupViews.popLast()
  }
  
  public func show(alert alertConfig: HelloAlertConfig) {
    blurBackgroundForPopup = true
    alertViewID = UUID().uuidString
    alertView = HelloAlert(config: alertConfig)
  }
  
  public func dismissAlert() {
    guard alertView != nil else { return }
    alertView = nil
  }
  
  public func present(sheet: @MainActor @autoclosure @escaping () -> some View) {
    blurBackgroundForPopup = false
    popupViews.append(PopupWindow { HelloSheet { _ in sheet() } })
  }
  
  public func present(view: @MainActor @autoclosure @escaping () -> some View) {
    blurBackgroundForPopup = false
    popupViews.append(PopupWindow { view() })
  }
  
  public func dismissSheet() {
    guard !popupViews.isEmpty else { return }
    popupViews.popLast()
  }
}

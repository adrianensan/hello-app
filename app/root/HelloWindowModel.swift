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
    var view: AnyView
  }
  
  var popupViews: [PopupWindow] = []
  var alertView: HelloAlert?
  
  var alertViewID: String = UUID().uuidString
  
  public func showPopup<Content: View>(_ view: Content) {
    popupViews.append(PopupWindow(id: UUID().uuidString, view: AnyView(view.id(UUID().uuidString))))
  }
  
  public func show(alert alertConfig: HelloAlertConfig) {
    alertViewID = UUID().uuidString
    alertView = HelloAlert(config: alertConfig)
  }
  
  public func dismissPopup() {
    guard !popupViews.isEmpty else { return }
    popupViews.popLast()
  }
  
  public func dismissAlert() {
    print("Dismissing alert")
//    guard alertView != nil else { return }
    alertView = nil
  }
}

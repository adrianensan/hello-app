import SwiftUI
import Observation

@MainActor
@Observable
public class HelloWindowModel {
  
  #if os(iOS)
  public weak var window: UIWindow?
  #endif
  
  public private(set) var popupView: AnyView?
  public private(set) var alertView: AnyView?
  
  public private(set) var popupViewID: String = UUID().uuidString
  public private(set) var alertViewID: String = UUID().uuidString
  
  
  public func showPopup<Content: View>(_ view: Content) {
    popupViewID = UUID().uuidString
    popupView = AnyView(view.id(UUID().uuidString))
  }
  
  public func show(alert alertConfig: HelloAlertConfig) {
    alertViewID = UUID().uuidString
    alertView = AnyView(HelloAlert(config: alertConfig).id(UUID().uuidString))
  }
  
  public func dismissPopup() {
    guard popupView != nil else { return }
    popupView = nil
  }
  
  public func dismissAlert() {
    guard alertView != nil else { return }
    alertView = nil
  }
}

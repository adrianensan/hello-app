import SwiftUI

@MainActor
public class HelloWindowModel: ObservableObject {
  
  #if os(iOS)
  public weak var window: UIWindow?
  #endif
  
  @Published public var popupView: AnyView?
  @Published public var alertView: AnyView?
  
  public var popupViewID: String = UUID().uuidString
  public var alertViewID: String = UUID().uuidString
  
  
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

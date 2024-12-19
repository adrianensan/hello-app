import SwiftUI

import HelloCore

public struct HelloButtonActionContext: Sendable {
  public var environment: EnvironmentValues
  public var buttonFrame: CGRect
}

public protocol HelloButtonAction: Sendable {
  @MainActor
  func action(context: HelloButtonActionContext) async throws
}

/// SwiftUI Button with an async throws action, haptics, and fully customizable label
//public extension HelloButton {
//  
//  public enum Action: Sendable {
//    case closure(@MainActor () async throws -> Void)
//    case showMenu(@MainActor () async throws -> [HelloMenuItem])
//    case pushPage(@MainActor () async throws -> PagerPage)
//#if os(iOS)
//    case presentSheet(@MainActor () async throws -> HelloSheetConfig)
//#elseif os(macOS)
//    case showToolTip(@MainActor () -> AnyView)
//    case showSubWindow(id: String = .uuid, @MainActor () -> AnyView)
//#endif
//    
//    public static func pushPage(name: String? = nil, content: @MainActor @escaping () -> some View) -> Action {
//      .pushPage { PagerPage(name: name, view: content) }
//    }
//    
//    public static func pushPage(id: String, name: String? = nil, content: @MainActor @escaping () -> some View) -> Action {
//      .pushPage { PagerPage(id: id, name: name, view: content) }
//    }
//    
//#if os(iOS)
//    public static func presentSheet(content: @MainActor @escaping () -> some View) -> Action {
//      .presentSheet { HelloSheetConfig(view: content) }
//    }
//#elseif os(macOS)
//    public static func showPopup<PopupContent: View>(id: String = String(describing: PopupContent.self), content: @MainActor @escaping () -> PopupContent) -> Action {
//      .showSubWindow(id: id) { AnyView(content()) }
//    }
//#endif
//  }
//}

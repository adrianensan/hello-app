import SwiftUI

public struct HelloPageNavBarContent<NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.helloPagerConfig) private var config
  @Environment(\.pageID) private var pageID
  @OptionalEnvironment(HelloPagerModel.self) private var pagerModel
  #if os(iOS)
  @OptionalEnvironment(HelloSheetModel.self) private var sheetModel
  #endif
  
  @ViewBuilder private var navBarContent: @MainActor () -> NavBarContent
  
  public init(@ViewBuilder navBarContent: @escaping @MainActor () -> NavBarContent) {
    self.navBarContent = navBarContent
  }
  
  public var body: some View {
    HStack(spacing: 0) {
      if let pagerModel, let pageID, pagerModel.canGoBack(from: pageID) {
        HelloBackButton()
      } else {
        Color.clear
          .frame(width: config.horizontalPagePadding)
      }
      Spacer(minLength: 0)
      navBarContent()
      Spacer(minLength: 0)
      #if os(iOS)
      if let sheetModel {
        HelloCloseButton(onDismiss: { sheetModel.dismiss() })
          .foregroundStyle(theme.header.foreground.primary.style)
          .backgroundStyle(theme.header.backgroundColor)
      } else {
        Color.clear
          .frame(width: config.horizontalPagePadding)
      }
      #endif
    }
  }
}

import SwiftUI

public struct HelloBackButton: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.pageID) private var pageID
  @Environment(\.safeArea) private var safeAreaInsets
  @Environment(\.helloPagerConfig) private var config
  @Environment(HelloPagerModel.self) private var pagerModel
  @Environment(BackProgressModel.self) private var backProgressModel
  
  public init() {
  }
  
  public var body: some View {
    HelloButton(action: { pagerModel.popView() }) {
      BackButton()
        .foregroundStyle(theme.text.primary.color)
        .padding(.leading, 8)
    }.zIndex(4)
      .frame(height: config.navBarHeight)
  }
}

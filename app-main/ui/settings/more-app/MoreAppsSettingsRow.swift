#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct MoreAppsSettingsRow: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloPagerModel.self) private var pagerModel
  
  public init() {}
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      pagerModel.push(name: "More Apps") { MoreAppsSettingsPage() }
    }) {
      HelloNavigationRow(icon: "arrowshape.down", name: "More Apps", actionIcon: .arrow) {
        OtherHelloAppsView(size: 24)
          .frame(height: 8)
      }
    }
  }
}
#endif

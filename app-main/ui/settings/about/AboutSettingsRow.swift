#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct AboutSettingsRow: View {
  
  @Environment(\.theme) private var theme
  @Environment(PagerModel.self) private var pagerModel
  
  public init() {}
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(name: "About") { AboutSettingsPage() }
    }) {
      HelloNavigationRow(icon: "info.circle", name: "About", actionIcon: .arrow) {
        Text("Version " + AppInfo.version)
          .font(.system(size: 16, weight: .regular))
      }
    }
  }
}
#endif

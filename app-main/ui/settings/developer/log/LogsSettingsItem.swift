#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

struct LogsSettingsItem: View {
  
  @Environment(PagerModel.self) private var pagerModel
  
  var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      pagerModel.push { LogsHelloPage() }
    }) {
      HelloNavigationRow(icon: "apple.terminal", name: "Logs", actionIcon: .arrow)
    }
  }
}
#endif

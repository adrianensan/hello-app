#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

struct LogsSettingsItem: View {
  
  @Environment(PagerModel.self) private var pagerModel
  
  var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      pagerModel.push { LogsNavigationPage() }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "apple.terminal")
            .font(.system(size: 20, weight: .regular, design: .rounded))
            .frame(width: 32, height: 32)
          
          Text("Logs")
            .font(.system(size: 16, weight: .regular, design: .rounded))
          Spacer(minLength: 0)
          Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .regular, design: .rounded))
        }
      }
    }
  }
}
#endif

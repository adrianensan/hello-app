#if os(iOS)
import SwiftUI

import HelloCore

public struct AboutSettingsRow: View {
  
  @Environment(PagerModel.self) private var pagerModel
  
  public init() {}
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(name: "About") { AboutSettingsPage() }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "info.circle")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          
          Text("About")
            .font(.system(size: 16, weight: .regular))
          Spacer(minLength: 0)
          Text("Version " + AppInfo.version)
            .font(.system(size: 16, weight: .regular))
          Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .regular))
        }
      }
    }
  }
}
#endif

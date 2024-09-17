#if os(iOS)
import SwiftUI

import HelloCore

public struct MoreAppsSettingsRow: View {
  
  @Environment(PagerModel.self) private var pagerModel
  
  public init() {}
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(name: "More Apps") { MoreAppsSettingsPage() }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "arrowshape.down")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          
          Text("More Apps")
            .font(.system(size: 16, weight: .regular))
          Spacer(minLength: 0)
          OtherHelloAppsView(size: 24)
            .frame(height: 8)
          Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .regular))
        }
      }
    }
  }
}
#endif

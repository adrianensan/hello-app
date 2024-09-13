#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct ScreenMetricsRow: View {
  
  @Environment(PagerModel.self) private var pagerModel
  
  public init() {}
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(name: "UI Metrics") { ScreenMetricsPage() }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "ruler")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          
          Text("UI Metrics")
            .font(.system(size: 16, weight: .regular))
          Spacer(minLength: 0)
          Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .regular))
        }
      }
    }
  }
}
#endif

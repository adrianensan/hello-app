#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct UIMetricsRow: View {
  
  @Environment(PagerModel.self) private var pagerModel
  
  public init() {}
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(name: "UI Metrics") { UIMetricsPage() }
    }) {
      HelloNavigationRow(icon: "ruler", name: "UI Metrics", actionIcon: .arrow)
    }
  }
}
#endif
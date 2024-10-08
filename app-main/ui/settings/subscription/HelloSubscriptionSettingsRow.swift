#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

public struct HelloSubscriptionSettingsRow: View {
  
  @Environment(\.theme) private var theme
  @Environment(PagerModel.self) private var pagerModel
  
  let subcriptionModel: HelloSubscriptionModel = .main
  
  public init() {
  }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(name: "Subscription") { HelloSubscriptionPage() }
    }) {
      HelloNavigationRow(icon: "bag", name: "Hello World", actionIcon: .arrow) {
        if subcriptionModel.isActuallySubscribed {
          Image(systemName: "heart.fill")
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(HelloColor.retroApple.red.swiftuiColor)
        }
      }
    }
  }
}
#endif

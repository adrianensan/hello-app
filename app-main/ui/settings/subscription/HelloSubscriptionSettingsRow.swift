#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

public struct HelloSubscriptionSettingsRow: View {
  
  @Environment(PagerModel.self) private var pagerModel
  
  let subcriptionModel: HelloSubscriptionModel = .main
  
  public init() {
  }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(name: "Subscription") { HelloSubscriptionPage() }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "bag")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          
          Text("Hello World")
            .font(.system(size: 16, weight: .regular))
          Spacer(minLength: 0)
          if subcriptionModel.isActuallySubscribed {
            Image(systemName: "heart.fill")
              .font(.system(size: 20, weight: .regular))
              .foregroundStyle(HelloColor.retroApple.red.swiftuiColor)
          }
          Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .regular))
        }
      }
    }
  }
}
#endif

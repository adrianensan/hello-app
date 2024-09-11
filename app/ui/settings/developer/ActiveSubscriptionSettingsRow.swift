import SwiftUI

import HelloCore

struct ActiveSubscriptionSettingsRow: View {
  
  let subscriptionModel: HelloSubscriptionModel = .main
  
  var body: some View {
    HelloSectionItem {
      HStack(spacing: 4) {
        Image(systemName: "dollarsign")
          .font(.system(size: 20, weight: .regular))
          .frame(width: 32, height: 32)
        Text("Enable Developer Subscription")
          .font(.system(size: 16, weight: .regular))
        Spacer(minLength: 0)
        HelloToggle(isSelected: subscriptionModel.isDeveloperSubscribed) {
          subscriptionModel.set(developerIsSubscribed: !subscriptionModel.isDeveloperSubscribed)
        }
      }
    }
  }
}

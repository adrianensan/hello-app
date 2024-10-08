import SwiftUI

import HelloCore
import HelloApp

struct ActiveSubscriptionSettingsRow: View {
  
  let subscriptionModel: HelloSubscriptionModel = .main
  
  var body: some View {
    if !subscriptionModel.allowPremiumFeatures || subscriptionModel.isDeveloperEnabled {
      HelloNavigationRow(icon: "dollarsign", name: "Enable Premium Features") {
        HelloToggle(isSelected: subscriptionModel.isDeveloperEnabled) {
          subscriptionModel.set(developerIsSubscribed: !subscriptionModel.isDeveloperEnabled)
        }
      }
    }
  }
}

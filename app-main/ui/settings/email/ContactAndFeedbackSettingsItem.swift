#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct ContactAndFeedbackSettingsItem: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  
  public init() {}  
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      windowModel.presentSheet { EmailSetupSheet() }
    }) {
      HelloNavigationRow(icon: "envelope", name: "Contact/Feedback", actionIcon: .arrow)
    }
  }
}
#endif

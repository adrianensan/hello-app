#if os(iOS)
import SwiftUI

import HelloCore

public struct ContactAndFeedbackSettingsItem: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  
  public init() {}  
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      windowModel.presentSheet { EmailSetupSheet() }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "envelope")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          Text("Contact/Feedback")
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

import SwiftUI

import HelloCore

public struct ContactAndFeedbackSettingsItem: View {
  
  @Environment(\.openURL) private var openURL
  
  private let mailLink = URL(string: """
    mailto:adrianensan@me.com?subject=\(AppInfo.displayName) Feedback&body=
    
    ---DEBUG-INFO---
    \(Device.current.description), \(OSInfo.description)
    """)
  
  public init() {}
  
  public var body: some View {
    if let mailLink {
      HelloButton(clickStyle: .highlight, haptics: .click, action: {
        openURL(mailLink)
      }) {
        HelloSectionItem {
          HStack(spacing: 4) {
            Image(systemName: "envelope")
              .font(.system(size: 20, weight: .regular))
              .frame(width: 32, height: 32)
            Text("Contact/Feedback")
              .font(.system(size: 16, weight: .regular))
            Spacer(minLength: 0)
            Image(systemName: "arrow.up.forward.app")
              .font(.system(size: 16, weight: .regular))
          }
        }
      }
    }
  }
}

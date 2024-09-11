import SwiftUI

import HelloCore

@MainActor
public struct PrivacyPolicySettingsPage: View {
  
  @Environment(\.theme) var theme
  
  public var body: some View {
    NavigationPage(title: "Privacy Policy") {
      Text("\(AppInfo.displayName) does not collect any information.\n\nThat's it!")
        .font(.system(size: 14, weight: .medium))
        .fontDesign(.monospaced)
        .multilineTextAlignment(.center)
        .foregroundStyle(theme.foreground.primary.style)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
    }
  }
}

import SwiftUI

import HelloCore

@MainActor
public struct TechnicalDetailsSettingsPage: View {
  
  @Environment(\.theme) var theme
  
  public var body: some View {
    NavigationPage(title: "Technical Details") {
      Text("""
        \(AppInfo.displayName) is written entirely in Swift 6, with SwiftUI for all the UI.
        
        A custom UI and business logic package is shared across all Hello apps, making it much easier to maintain multiple apps. \
        Over half the total number of lines of code of \(AppInfo.displayName) come from this shared package.
        
        **UI**
        While the built-in SwiftUI components make it easy and fast to throw UI together, they are also extremely limiting. \
        Every component you see has been recreated, allowing for full custmization and lots of fun interactivity. \
        This includes all navigationm sheets, popups, toggles, and lists. \
          
        The custom UI allows for many fun interactions you may have noticed, including:
        - Full themeing of every single component
        - Navigation titles smoothly flow down when scrolled to the top
        - Back buttons animate when swiping back a page (try slowly swiping back to dismiss this page)
        - Close buttons animate when dismissing a sheet (try slowly siping down to dismiss this page)
        
        No third party dependencies were used.
        
        If you'd like to explore some develper/debug stuff, tap the logo at the bottom of the settings page 10 times, and enter "ADMIN"
        """)
      .font(.system(size: 14, weight: .regular))
      .fontDesign(.monospaced)
      .multilineTextAlignment(.leading)
      .foregroundStyle(theme.foreground.primary.style)
      .lineLimit(nil)
      .fixedSize(horizontal: false, vertical: true)
      .padding(.horizontal, 16)
    }
  }
}

#if os(iOS)
import SwiftUI

import HelloCore

struct AboutSettingsPage: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeArea
  
  var body: some View {
    NavigationPage(title: "About") {
      AboutSettingsPageContent()
    }
  }
}
#endif

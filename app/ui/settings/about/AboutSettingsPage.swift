#if os(iOS)
import SwiftUI

import HelloCore

struct AboutSettingsPage: View {
  
  var body: some View {
    NavigationPage(title: "About") {
      AboutSettingsPageContent()
    }
  }
}
#endif

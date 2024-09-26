#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct AboutSettingsPage: View {
  
  var body: some View {
    NavigationPage(title: "About") {
      AboutSettingsPageContent()
    }
  }
}
#endif

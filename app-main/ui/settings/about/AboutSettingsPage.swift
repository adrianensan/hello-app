#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct AboutSettingsPage: View {
  
  var body: some View {
    HelloPage(title: "About") {
      AboutSettingsPageContent()
    }
  }
}
#endif

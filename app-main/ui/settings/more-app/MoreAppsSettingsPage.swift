#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct MoreAppsSettingsPage: View {
  
  var body: some View {
    HelloPage(title: "More Apps") {
      MoreAppsSettingsPageContent()
    }
  }
}
#endif

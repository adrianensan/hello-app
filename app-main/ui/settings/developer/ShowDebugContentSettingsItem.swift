import SwiftUI

import HelloCore
import HelloApp

struct ShowDebugContentSettingsItem: View {
  
  @Persistent(.showDebugContent) private var showDebugContent
  
  var body: some View {
    HelloNavigationRow(icon: "ladybug", name: "Show Debug Content") {
      HelloToggle(_showDebugContent)
    }
  }
}

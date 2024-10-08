import SwiftUI

import HelloCore
import HelloApp

struct ShowTouchesSettingsItem: View {
  
  @Persistent(.showTouches) private var showTouches
  
  var body: some View {
    HelloNavigationRow(icon: "hand.tap", name: "Show Touches") {
      HelloToggle(_showTouches)
    }
  }
}

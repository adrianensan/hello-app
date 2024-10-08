import SwiftUI

import HelloCore
import HelloApp

struct ShowDebugBordersSettingsItem: View {
  
  @Persistent(.showDebugBorders) private var showDebugBorders
  
  var body: some View {
    HelloNavigationRow(icon: "squareshape", name: "Show Debug Borders") {
      HelloToggle(isSelected: showDebugBorders) {
        showDebugBorders.toggle()
        DebugModel.main.showBorders = showDebugBorders
      }
    }
  }
}

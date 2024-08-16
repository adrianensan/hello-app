import SwiftUI

import HelloCore
import HelloApp

struct ShowDebugBordersSettingsItem: View {
  
  @Persistent(.showDebugBorders) private var showDebugBorders
  
  var body: some View {
    HelloSectionItem {
      HStack(spacing: 4) {
        Image(systemName: "squareshape")
          .font(.system(size: 20, weight: .regular, design: .rounded))
          .frame(width: 32, height: 32)
        Text("Show Debug Borders")
          .font(.system(size: 16, weight: .regular, design: .rounded))
        Spacer(minLength: 0)
        HelloToggle(isSelected: showDebugBorders) {
          showDebugBorders.toggle()
          DebugModel.main.showBorders = showDebugBorders
        }
      }
    }
  }
}

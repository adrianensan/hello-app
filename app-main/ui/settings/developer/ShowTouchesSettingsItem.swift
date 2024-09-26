import SwiftUI

import HelloCore
import HelloApp

struct ShowTouchesSettingsItem: View {
  
  @Persistent(.showTouches) private var showTouches
  
  var body: some View {
    HelloSectionItem {
      HStack(spacing: 4) {
        Image(systemName: "hand.tap")
          .font(.system(size: 20, weight: .regular))
          .frame(width: 32, height: 32)
        Text("Show Touches")
          .font(.system(size: 16, weight: .regular))
        Spacer(minLength: 0)
        HelloToggle(isSelected: showTouches) {
          showTouches.toggle()
        }
      }
    }
  }
}

import SwiftUI

import HelloCore

struct ShowDebugContentSettingsItem: View {
  
  @Persistent(.showDebugContent) private var showDebugContent
  
  var body: some View {
    HelloSectionItem {
      HStack(spacing: 4) {
        Image(systemName: "ladybug")
          .font(.system(size: 20, weight: .regular, design: .rounded))
          .frame(width: 32, height: 32)
        Text("Show Debug Content")
          .font(.system(size: 16, weight: .regular, design: .rounded))
        Spacer(minLength: 0)
        HelloToggle(isSelected: showDebugContent) {
          showDebugContent.toggle()
        }
      }
    }
  }
}

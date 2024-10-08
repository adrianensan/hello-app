import SwiftUI

import HelloCore
import HelloApp

struct DisableViewMaskingSettingsItem: View {
  
  @Persistent(.disableMasking) private var disableMasking
  
  var body: some View {
    HelloNavigationRow(icon: "squareshape", name: "Disable Masking") {
      HelloToggle(isSelected: disableMasking) {
        disableMasking.toggle()
      }
    }
  }
}

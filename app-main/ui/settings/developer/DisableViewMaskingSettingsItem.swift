import SwiftUI

import HelloCore
import HelloApp

struct DisableViewMaskingSettingsItem: View {
  
  @Persistent(.maskToDeviceShape) private var maskToDeviceShape
  
  var body: some View {
    HelloNavigationRow(icon: "squareshape", name: "Mask To Device Shape") {
      HelloToggle(isSelected: maskToDeviceShape) {
        maskToDeviceShape.toggle()
      }
    }
  }
}

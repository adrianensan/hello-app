#if os(macOS)
import SwiftUI

struct BehindWindowBlur: NSViewRepresentable {
  let material: NSVisualEffectView.Material
  let blendingMode: NSVisualEffectView.BlendingMode
  let isDark: Bool = true
  
  func makeNSView(context: Context) -> NSVisualEffectView
  {
    let visualEffectView = NSVisualEffectView()
    visualEffectView.material = material
    visualEffectView.blendingMode = blendingMode
    visualEffectView.state = .active
    visualEffectView.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
    return visualEffectView
  }
  
  func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context)
  {
    visualEffectView.material = material
    visualEffectView.blendingMode = blendingMode
    visualEffectView.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
  }
}
#endif

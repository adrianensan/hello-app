#if os(macOS)
import SwiftUI

public struct BehindWindowBlur: NSViewRepresentable {
  
  @Environment(\.colorScheme) var colorScheme
  
  let material: NSVisualEffectView.Material
  var isBaseLayer: Bool
  var nsAppearance: NSAppearance.Name {
    switch colorScheme {
    case .dark: return .vibrantDark
    case .light: fallthrough
    @unknown default: return .vibrantLight
    }
  }
  
  public init(material: NSVisualEffectView.Material = .fullScreenUI, isBaseLayer: Bool) {
    self.material = material
    self.isBaseLayer = isBaseLayer
  }
  
  public func makeNSView(context: Context) -> NSVisualEffectView {
    let visualEffectView = NSVisualEffectView()
    visualEffectView.material = material
    visualEffectView.blendingMode = isBaseLayer ? .behindWindow : .withinWindow
    visualEffectView.state = .active
    visualEffectView.appearance = NSAppearance(named: nsAppearance)
    return visualEffectView
  }
  
  public func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
    visualEffectView.material = material
    visualEffectView.blendingMode = isBaseLayer ? .behindWindow : .withinWindow
    visualEffectView.appearance = NSAppearance(named: nsAppearance)
  }
}
#endif

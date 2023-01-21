import SwiftUI

import HelloCore

public extension Color {
  var helloColor: HelloColor {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var o: CGFloat = 0
    
#if os(iOS)
    guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
      // You can handle the failure here as you want
      return .transparent
    }
#else
    NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
#endif
    
    return HelloColor(r: r, g: g, b: b, a: o)
  }
}

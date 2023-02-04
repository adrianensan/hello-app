import SwiftUI

import HelloCore

#if canImport(UIKit)
public typealias NativeColor = UIColor
#elseif canImport(AppKit)
public typealias NativeColor = NSColor
#endif

public extension HelloColor {
  var nativeColor: NativeColor {
    NativeColor(displayP3Red: r, green: g, blue: b, alpha: a)
  }
  
  var swiftuiColor: Color {
    Color(.displayP3, red: r, green: g, blue: b, opacity: a)
  }
}

public extension HelloDynamicColor {
  var nativeColor: NativeColor {
    #if os(iOS)
    NativeColor { traitCollection in
      switch traitCollection.userInterfaceStyle {
      case .dark: return dark.nativeColor
      default: return light.nativeColor
      }
    }
    #elseif os(macOS)
    NativeColor(name: nil) { appearance in
      switch appearance.name {
      case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
        return dark.nativeColor
      default:
        return light.nativeColor
      }
    }
    #endif
  }
  
  var swiftuiColor: Color {
    Color(nativeColor)
  }
}

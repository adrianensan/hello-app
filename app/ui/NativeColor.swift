import SwiftUI

import HelloCore

#if os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
public typealias NativeColor = UIColor
#elseif os(macOS)
public typealias NativeColor = NSColor
#endif

public extension HelloColorSpace {
  var swiftuiColorSpace: Color.RGBColorSpace {
    switch self {
    case .sRGB: .sRGB
    case .p3: .displayP3
    }
  }
}

public extension HelloColor {
  var nativeColor: NativeColor {
    switch colorSpace {
    case .p3:
      NativeColor(displayP3Red: r, green: g, blue: b, alpha: a)
    case .sRGB:
      NativeColor(red: r, green: g, blue: b, alpha: a)
    }
  }
  
  var swiftuiColor: Color {
    Color(colorSpace.swiftuiColorSpace, red: r, green: g, blue: b, opacity: a)
  }
}

public extension HelloDynamicColor {
  var nativeColor: NativeColor {
    #if os(iOS) || os(tvOS)
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
    #elseif os(watchOS) || os(visionOS)
    return light.nativeColor
    #endif
  }
  
  var swiftuiColor: Color {
    Color(nativeColor)
  }
}

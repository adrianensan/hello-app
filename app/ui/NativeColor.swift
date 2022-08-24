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

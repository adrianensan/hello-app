import Foundation

public typealias HelloColour = HelloColor

public enum HelloColorSpace: String, Codable, Equatable, Hashable, Identifiable, Sendable {
  case sRGB
  case p3
  
  public var id: String { rawValue }
}

public struct HelloColor: Codable, Equatable, Hashable, Identifiable, Sendable, CustomStringConvertible {
  public var r: Double
  public var g: Double
  public var b: Double
  public var a: Double
  public var colorSpace: HelloColorSpace
  
  static func cap(_ value: Double) -> Double {
    min(1, max(0, value))
  }
  
  public init(r: Double, g: Double, b: Double, a: Double = 1, colorSpace: HelloColorSpace = .p3) {
    self.r = Self.cap(r)
    self.g = Self.cap(g)
    self.b = Self.cap(b)
    self.a = Self.cap(a)
    self.colorSpace = colorSpace
  }
  
  public init(h: Double, s: Double, b: Double, a: Double = 1, colorSpace: HelloColorSpace = .p3) {
    let h = Self.cap(h)
    let s = Self.cap(s)
    let b = Self.cap(b)
    let maxV = b
    let minV = maxV * (1 - s)
    
    let z = (maxV - minV) * (1 - abs((h * 6).truncatingRemainder(dividingBy: 2) - 1))
    
    let section = Int(h * 6)
    switch section {
    case 0:
      self.r = maxV
      self.g = z + minV
      self.b = minV
    case 1:
      self.r = z + minV
      self.g = maxV
      self.b = minV
    case 2:
      self.r = minV
      self.g = maxV
      self.b = z + minV
    case 3:
      self.r = minV
      self.g = z + minV
      self.b = maxV
    case 4:
      self.r = z + minV
      self.g = minV
      self.b = maxV
    default:
      self.r = maxV
      self.g = minV
      self.b = z + minV
    }
    self.a = Self.cap(a)
    self.colorSpace = colorSpace
  }
  
  public init?(hexCode: String) {
    let hexCode: String = hexCode.trimmingCharacters(in: .whitespacesAndNewlines).deletingPrefix("#")
    
    let scanner = Scanner(string: hexCode)
    var hexNumber: UInt64 = 0
    
    guard hexCode.count == 6, scanner.scanHexInt64(&hexNumber) else {
      return nil
    }
    
    self.init(r: Double((hexNumber & 0xFF0000) >> 16) / 255.0,
              g: Double((hexNumber & 0x00FF00) >> 8) / 255.0,
              b: Double((hexNumber & 0x0000FF)) / 255.0,
              colorSpace: .sRGB)
  }
  
  public var id: Double {
    r * 1000_000_000 + g * 1000_000 + b * 1000 + a
  }
  
  public var light: HelloColor { self }
  
  public var dark: HelloColor { self }
  
  public func opacity(_ alpha: CGFloat) -> HelloColor {
    HelloColor(r: r, g: g, b: b, a: a * alpha, colorSpace: colorSpace)
  }
  
  public var brightness: Double {
    r * 0.225 + g * 0.7 + b * 0.075
  }
  
  public var isDark: Bool {
    withFakeAlpha(a, background: .black).brightness < 0.7
  }
  
  public var isDim: Bool {
    withFakeAlpha(a, background: .black).brightness < 0.4
  }
  
  public var isGreyscale: Bool {
    r == b && b == g
  }
  
  public var isOpaque: Bool {
    a == 1
  }
  
  public var isEssentiallyGreyscale: Bool {
    abs(r - b) < 0.1 && abs(b - g) < 0.1
  }
  
  public var isEffectivelyBlack: Bool {
    r <= 0.1 && g <= 0.1 && b <= 0.1
  }
  
  public var isEffectivelyWhite: Bool {
    r > 0.92 && g > 0.92 && b > 0.92
  }
  
  public var readableOverlayColor: HelloColor {
    isDark ? .white : .black
  }
  
  public var description: String {
    "(r: \(String(format: "%.2f", r)), g: \(String(format: "%.2f", g)), b: \(String(format: "%.2f", b)), a: \(String(format: "%.2f", a)))"
  }
  
  public var alpha: CGFloat { a }
  
  public var hsb: (Double, Double, Double) {
    let minV = min(r, g, b)
    let maxV = max(r, g, b)
    let delta = maxV - minV
    
    var hue: Double
    if delta == 0 {
      hue = 0
    } else if r == maxV {
      hue = (g - b) / delta
    } else if g == maxV {
      hue = 2 + (b - r) / delta
    } else {
      hue = 4 + (r - g) / delta
    }
    hue *= 60
    if hue < 0 {
      hue += 360
    }
    hue /= 360
    let saturation = maxV == 0 ? 0 : (delta / maxV)
    let brightness = maxV
    
    return (hue, saturation, brightness)
  }
  
  public func modify(saturation: Double, brightness: Double) -> HelloColor {
    var (h, s, b) = hsb
    if s > 0 {
      s += saturation
    }
    
    b += brightness
    return HelloColor(h: h, s: s, b: b, a: a, colorSpace: colorSpace)
  }
  
  public func withFakeAlpha(_ alpha: Double, background: HelloColor = .black) -> HelloColor {
    HelloColor(r: r * alpha + background.r * (1 - alpha),
               g: g * alpha + background.g * (1 - alpha),
               b: b * alpha + background.b * (1 - alpha),
               a: a,
               colorSpace: colorSpace)
  }
  
  public func darken(by darkenAmount: Double) -> HelloColor {
    HelloColor(r: r * darkenAmount,
               g: g * darkenAmount,
               b: b * darkenAmount,
               a: a,
               colorSpace: colorSpace)
  }
  
  public func isEssentiallySame(as otherColor: HelloColor) -> Bool {
    abs(r - otherColor.r) < 0.001 && abs(g - otherColor.g) < 0.001
    && abs(b - otherColor.b) < 0.001 && abs(a - otherColor.a) < 0.001
  }
  
  public func isSimilar(to otherColor: HelloColor) -> Bool {
    let rDiff: Double = abs(r - otherColor.r)
    let gDiff: Double = abs(g - otherColor.g)
    let bDiff: Double = abs(b - otherColor.b)
    let diff: Double = rDiff + gDiff + bDiff
    return diff / 3 < 0.1
  }
  
  public func lighten() -> HelloColor {
    modify(saturation: 0, brightness: 0.4)
  }
  
  public func darken() -> HelloColor {
    modify(saturation: 0, brightness: -0.3)
  }
}

public extension HelloColor {
  static var transparent: HelloColor { HelloColor(r: 0, g: 0, b: 0, a: 0) }
  static var black: HelloColor { HelloColor(r: 0, g: 0, b: 0) }
  static var white: HelloColor { HelloColor(r: 1, g: 1, b: 1) }
  
  static var monkeyOrange: HelloColor { HelloColor(r: 0.8, g: 0.4, b: 0.2) }
  
  static var pink: HelloColor { HelloColor(r: 0.6, g: 0.4, b: 0.4) }
  static var fullBlue: HelloColor { HelloColor(r: 0, g: 0, b: 1) }
  static var fullGreen: HelloColor { HelloColor(r: 0, g: 1, b: 0) }
  static var darkGreen: HelloColor { HelloColor(r: 0.2, g: 0.5, b: 0.15) }
  static var darkBlue: HelloColor { HelloColor(r: 0, g: 0, b: 0.5) }
  static var fullOrange: HelloColor { HelloColor(r: 1, g: 0.5, b: 0) }
  static var skyBlue: HelloColor { HelloColor(r: 0.41, g: 0.57, b: 0.96) }
  static var twitter: HelloColor { HelloColor(r: 0.12, g: 0.63, b: 0.96) }
  
  static var solitaireAccent: HelloColor { HelloColor(r: 0.25, g: 0.7, b: 0.25) }
  static var snapchat: HelloColor { HelloColor(r: 1, g: 0.99, b: 0.02) }
  
  static var dark: HelloColor { HelloColor(r: 0.14, g: 0.14, b: 0.14) }
  static var darker: HelloColor { HelloColor(r: 0.1, g: 0.1, b: 0.1) }
  static var light: HelloColor { HelloColor(r: 0.9, g: 0.9, b: 0.9) }
  static var oldWhite: HelloColor { HelloColor(r: 0.95, g: 0.95, b: 0.91) }
  static var offWhite: HelloColor { HelloColor(r: 0.95, g: 0.95, b: 0.95) }
  
  static var dimWhite: HelloColor { HelloColor(r: 0.5, g: 0.5, b: 0.5) }
  static var veryDimWhite: HelloColor { HelloColor(r: 0.35, g: 0.35, b: 0.35) }
  static var veryDimRed: HelloColor { HelloColor(r: 0.5, g: 0.1, b: 0.1) }
  static var dimRed: HelloColor { HelloColor(r: 0.6, g: 0.1, b: 0.1) }
  
  static var fadedRed: HelloColor { HelloColor(r: 0.9, g: 0, b: 0) }
  static var fullRed: HelloColor { HelloColor(r: 1.0, g: 0, b: 0) }
  
  static var darkGrey: HelloColor { HelloColor(r: 0.32, g: 0.32, b: 0.32) }
  static var darkerGrey: HelloColor { HelloColor(r: 0.26, g: 0.26, b: 0.26) }
  
  static var neonGreen: HelloColor { HelloColor(r: 0.1, g: 0.8, b: 0.1) }
  
  static var darkThemeBlueAccent: HelloColor { HelloColor(r: 0.23, g: 0.51, b: 0.97) }
  static var lightThemeBlueAccent: HelloColor { HelloColor(r: 0.2, g: 0.47, b: 0.96) }
}

public struct HelloDynamicColor: Sendable {
  
  public var light: HelloColor
  public var dark: HelloColor
  
  public init(light: HelloColor, dark: HelloColor) {
    self.light = light
    self.dark = dark
  }
  
  public init(r: Double, g: Double, b: Double, a: Double = 1) {
    self.light = HelloColor(r: r, g: g, b: b, a: a)
    self.dark = HelloColor(r: r, g: g, b: b, a: a)
  }
  
  public var readableOverlayColor: HelloDynamicColor {
    HelloDynamicColor(light: light.readableOverlayColor,
                      dark: dark.readableOverlayColor)
  }
}

public extension HelloColor {
  static func *(left: Self, right: Float) -> Self {
    let right = Double(right)
    return HelloColor(r: left.r * right, g: left.g * right, b: left.b * right, a: left.a * right)
  }
  
  static func +(left: Self, right: Self) -> Self {
    HelloColor(r: left.r + right.r, g: left.g + right.g, b: left.b + right.b, a: left.a + right.a)
  }
}

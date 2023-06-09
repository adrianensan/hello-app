import SwiftUI

public enum Pattern {}

public extension Pattern {
  
  enum retroApple {}
  enum pride {}
  
  static var facebook: FacebookBackgroundView { .init() }
  static var instagram: InstagramBackgroundView { .init() }
}

public extension Pattern.retroApple {
  static var horizontal: RetroAppleColorsHorizontal { .init() }
  static var vertical: RetroAppleColorsVertical { .init() }
}

public extension Pattern.pride {
  static var horizontal: PrideColorsHorizontal { .init() }
  static var vertical: PrideColorsVertical { .init() }
}

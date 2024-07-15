import SwiftUI

public enum Pattern {}

@MainActor
public extension Pattern {
  
  enum retroApple {}
  enum pride {}
  
  static var facebook: FacebookBackgroundView { .init() }
  static var instagram: InstagramBackgroundView { .init() }
}

@MainActor
public extension Pattern.retroApple {
  static var horizontal: RetroAppleColorsHorizontal { .init() }
  static var vertical: RetroAppleColorsVertical { .init() }
}

@MainActor
public extension Pattern.pride {
  static var horizontal: PrideColorsHorizontal { .init() }
  static var vertical: PrideColorsVertical { .init() }
}

import SwiftUI

import HelloCore

public struct RetroAppleColorsHorizontal: View {
  
  public init() { }
  
  public var body: some View {
    HStack(spacing: 0) {
      HelloColor.retroApple.green.swiftuiColor
      HelloColor.retroApple.yellow.swiftuiColor
      HelloColor.retroApple.orange.swiftuiColor
      HelloColor.retroApple.red.swiftuiColor
      HelloColor.retroApple.purple.swiftuiColor
      HelloColor.retroApple.blue.swiftuiColor
    }
  }
}

public struct RetroAppleColorsVertical: View {
  
  public init() { }
  
  public var body: some View {
    VStack(spacing: 0) {
      HelloColor.retroApple.green.swiftuiColor
      HelloColor.retroApple.yellow.swiftuiColor
      HelloColor.retroApple.orange.swiftuiColor
      HelloColor.retroApple.red.swiftuiColor
      HelloColor.retroApple.purple.swiftuiColor
      HelloColor.retroApple.blue.swiftuiColor
    }
  }
}

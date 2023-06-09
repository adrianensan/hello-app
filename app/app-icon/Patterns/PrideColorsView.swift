import SwiftUI

import HelloCore

public struct PrideColorsHorizontal: View {
  
  public init() { }
  
  public var body: some View {
    HStack(spacing: 0) {
      HelloColor.pride.red.swiftuiColor
      HelloColor.pride.orange.swiftuiColor
      HelloColor.pride.yellow.swiftuiColor
      HelloColor.pride.green.swiftuiColor
      HelloColor.pride.blue.swiftuiColor
      HelloColor.pride.violet.swiftuiColor
    }
  }
}

public struct PrideColorsVertical: View {
  
  public init() { }
  
  public var body: some View {
    VStack(spacing: 0) {
      HelloColor.pride.red.swiftuiColor
      HelloColor.pride.orange.swiftuiColor
      HelloColor.pride.yellow.swiftuiColor
      HelloColor.pride.green.swiftuiColor
      HelloColor.pride.blue.swiftuiColor
      HelloColor.pride.violet.swiftuiColor
    }
  }
}

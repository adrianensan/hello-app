import SwiftUI

import HelloCore

public struct HelloBackgroundDimmingView: View {
  
  @Environment(\.colorScheme) private var colorScheme
  
  public init() {}
  
  private var fadeAmount: CGFloat {
    switch colorScheme {
    case .dark: 0.8
    default: 0.2
    }
  }
  
  public var body: some View {
    Color(red: 0.1, green: 0.1, blue: 0.1, opacity: fadeAmount)
  }
}

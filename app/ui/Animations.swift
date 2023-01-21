import SwiftUI

public extension Animation {
  static var ddampSpring: Animation {
    .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)
    .speed(1.25)
  }
  
  static var dampSpring: Animation {
    .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)
    .speed(1.25)
  }
  
  static var dartSpring: Animation {
    .spring(response: 0.5, dampingFraction: 0.4, blendDuration: 0.2)
    .speed(2)
  }
}

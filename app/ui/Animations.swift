import SwiftUI

public extension Animation {
  static var ddampSpring: Animation {
    .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)
    .speed(1.25)
  }
  
  static var dampSpring: Animation {
    .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
    .speed(1.25)
  }
  
  static var dartSpring: Animation {
    .spring(response: 0.5, dampingFraction: 0.4, blendDuration: 0.2)
    .speed(2)
  }
  
  static var fastStiffSpring: Animation {
    .spring(response: 0.25, dampingFraction: 0.8)
    .speed(2)
  }
  
  static var fastSpring: Animation {
    .spring(dampingFraction: 0.6)
    .speed(1.6)
  }
  
  static var basicSpring: Animation {
    .spring(dampingFraction: 0.4)
    .speed(1.25)
  }
  
  static var medSpring: Animation {
    .spring(dampingFraction: 0.6)
    .speed(1.25)
  }
  
}

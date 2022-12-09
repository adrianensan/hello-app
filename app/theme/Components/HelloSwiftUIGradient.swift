import SwiftUI

import HelloCore

public extension HelloGradient.GradientType {
  var startPoint: UnitPoint {
    switch self {
    case .topToBottom:
      return .top
    case .leftToRight:
      return .leading
    }
  }
  
  var endPoint: UnitPoint {
    switch self {
    case .topToBottom:
      return .bottom
    case .leftToRight:
      return .trailing
    }
  }
}

public extension HelloGradient {
  
  var gradient: LinearGradient {
    LinearGradient(colors: colors.map { $0.swiftuiColor }, startPoint: direction.startPoint, endPoint: direction.endPoint)
  }
}

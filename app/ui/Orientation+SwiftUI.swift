import SwiftUI

import HelloCore

public extension Orientation {
  var opposite: Orientation {
    switch self {
    case .horizontal: return .vertical
    case .vertical: return .horizontal
    }
  }
  
  var leadingEdge: Edge.Set {
    switch self {
    case .vertical: return .top
    case .horizontal: return .leading
    }
  }
  
  var trailingEdge: Edge.Set {
    switch self {
    case .vertical: return .bottom
    case .horizontal: return .trailing
    }
  }
  
  var leadingAlignment: Alignment {
    switch self {
    case .vertical: return .top
    case .horizontal: return .leading
    }
  }
  
  var leadingPoint: UnitPoint {
    switch self {
    case .vertical: return .top
    case .horizontal: return .leading
    }
  }
  
  var trailingPoint: UnitPoint {
    switch self {
    case .vertical: return .bottom
    case .horizontal: return .trailing
    }
  }
  
  var trailingAlignment: Alignment {
    switch self {
    case .vertical: return .bottom
    case .horizontal: return .trailing
    }
  }
  
  var edges: Edge.Set {
    switch self {
    case .horizontal: return .horizontal
    case .vertical: return .vertical
    }
  }
  
  var axis: Axis.Set {
    switch self {
    case .horizontal: return .horizontal
    case .vertical: return .vertical
    }
  }
}

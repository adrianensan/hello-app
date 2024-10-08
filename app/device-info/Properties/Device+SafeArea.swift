import Foundation

extension Device {

  public var statusBarHeight: Double {
    switch self {
    case .appleWatch(let model):
      switch model {
      case .series6_40mm, .seriesSE2_40mm: 28
      case .series6_44mm, .seriesSE2_44mm: 31
      case .series7_41mm, .series8_41mm, .series9_41mm: 34
      case .series7_45mm, .series8_45mm, .series9_45mm: 35
      case .ultra1, .ultra2: 35
      case .unknown: 34
      }
    case .simulator(let simulatedDevice): simulatedDevice.statusBarHeight
    default: 0
    }
  }
  
  public var horizontalPadding: Double {
    switch self {
    case .appleWatch(let model):
      switch model {
      case .series6_40mm, .seriesSE2_40mm: return 4
      case .series6_44mm, .seriesSE2_44mm: return 4
      case .series7_41mm, .series7_45mm, .series8_41mm, .series8_45mm, .series9_41mm, .series9_45mm: return 6
      case .ultra1, .ultra2: return 10
      case .unknown: return 6
      }
    case .simulator(let simulatedDevice): return simulatedDevice.horizontalPadding
    default: return 0
    }
  }
  
  public var verticalPadding: Double {
    switch self {
    case .appleWatch(let model):
      switch model {
      case .series6_40mm, .seriesSE2_40mm: return 4
      case .series6_44mm, .seriesSE2_44mm: return 6
      case .series7_41mm, .series7_45mm, .series8_41mm, .series8_45mm, .series9_41mm, .series9_45mm: return 10
      case .ultra1, .ultra2: return 10
      case .unknown: return 10
      }
    case .simulator(let simulatedDevice): return simulatedDevice.verticalPadding
    default: return 0
    }
  }
}

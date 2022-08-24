import Foundation

extension Device {

  public var statusBarHeight: Double {
    switch self {
    case .appleWatch(let model):
      switch model {
      case .series3_38mm: return 19
      case .series3_42mm: return 21
      case .series4_40mm, .series5_40mm, .series6_40mm, .seriesSE_40mm: return 28
      case .series4_44mm, .series5_44mm, .series6_44mm, .seriesSE_44mm: return 31
      case .series7_41mm: return 34
      case .series7_45mm: return 35
      case .unknown: return 34
      }
    case .simulator(let simulatedDevice): return simulatedDevice.statusBarHeight
    default: return 0
    }
  }
  
  public var horizontalPadding: Double {
    switch self {
    case .appleWatch(let model):
      switch model {
      case .series3_38mm, .series3_42mm: return 1
      case .series4_40mm, .series5_40mm, .series6_40mm, .seriesSE_40mm: return 4
      case .series4_44mm, .series5_44mm, .series6_44mm, .seriesSE_44mm: return 4
      case .series7_41mm, .series7_45mm: return 6
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
      case .series3_38mm, .series3_42mm: return 1
      case .series4_40mm, .series5_40mm, .series6_40mm, .seriesSE_40mm: return 4
      case .series4_44mm, .series5_44mm, .series6_44mm, .seriesSE_44mm: return 6
      case .series7_41mm, .series7_45mm: return 10
      case .unknown: return 10
      }
    case .simulator(let simulatedDevice): return simulatedDevice.verticalPadding
    default: return 0
    }
  }
}

import Foundation

extension Device {
  public var screenCornerRadius: Double {
    switch self {
    case .iPhone(let iPhoneModel):
      switch iPhoneModel {
      case .xs, .xsMax, ._11Pro, ._11ProMax: return 39
      case ._11, .xr: return 41.5
      case ._12mini, ._13mini: return 44
      case ._12, ._12Pro, ._13, ._13Pro, ._14: return 47
      case ._12ProMax, ._13ProMax, ._14Plus: return 53
      case ._14Pro, ._14ProMax, ._15, ._15Plus, ._15Pro, ._15ProMax: return 55 + 1/3
      default: return 0
      }
    case .iPad(let iPadModel):
      switch iPadModel {
      case .air4, .pro11Inch1, .pro11Inch2, .pro12Inch3, .pro12Inch4: return 18
      default: return 0
      }
    case .appleWatch(let model):
      switch model {
      case .series6_40mm, .seriesSE2_40mm: return 28
      case .series6_44mm, .seriesSE2_44mm: return 31
      case .series7_41mm, .series8_41mm, .series9_41mm: return 37
      case .series7_45mm, .series8_45mm, .series9_45mm: return 38
      case .ultra1, .ultra2: return 38
      case .unknown: return 37
      }
    case .simulator(let simulatedDevice): return simulatedDevice.screenCornerRadius
    default: return 0
    }
  }
  
  public var hasDynamicIsland: Bool {
    switch self {
    case .iPhone(let iPhoneModel):
      switch iPhoneModel {
      case .xs: false
      case .xsMax: false
      case .xr: false
      case ._11: false
      case ._11Pro: false
      case ._11ProMax: false
      case ._12mini: false
      case ._12: false
      case ._12Pro: false
      case ._12ProMax: false
      case ._13mini: false
      case ._13: false
      case ._13Pro: false
      case ._13ProMax: false
      case ._14: false
      case ._14Plus: false
      case ._14Pro: true
      case ._14ProMax: true
      case ._15: true
      case ._15Plus: true
      case ._15Pro: true
      case ._15ProMax: true
      case ._16: true
      case ._16Plus: true
      case ._16Pro: true
      case ._16ProMax: true
      case .se2: false
      case .se3: false
      case .unknown: false
      }
    case .simulator(let simulatedDevice): simulatedDevice.hasDynamicIsland
    default: false
    }
  }
}

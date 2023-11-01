import Foundation

extension Device {
  public var screenCornerRadius: Double {
    switch self {
    case .iPhone(let iPhoneModel):
      switch iPhoneModel {
      case .x, .xs, .xsMax, ._11Pro, ._11ProMax: return 39
      case ._11, .xr: return 41.5
      case ._12mini, ._13mini: return 44
      case ._12, ._12Pro, ._13, ._13Pro, ._14, ._14Pro, ._15, ._15Pro: return 47
      case ._12ProMax, ._13ProMax, ._14Plus, ._14ProMax, ._15Plus, ._15ProMax: return 53
      default: return 0
      }
    case .iPad(let iPadModel):
      switch iPadModel {
      case .air4, .pro11Inch1, .pro11Inch2, .pro12Inch3, .pro12Inch4: return 18
      default: return 0
      }
    case .appleWatch(let model):
      switch model {
      case .series3_38mm, .series3_42mm: return 0
      case .series4_40mm, .series5_40mm, .series6_40mm, .seriesSE_40mm: return 28
      case .series4_44mm, .series5_44mm, .series6_44mm, .seriesSE_44mm: return 31
      case .series7_41mm, .series8_41mm, .series9_41mm: return 37
      case .series7_45mm, .series8_45mm, .series9_45mm: return 38
      case .ultra1, .ultra2: return 38
      case .unknown: return 37
      }
    case .simulator(let simulatedDevice): return simulatedDevice.screenCornerRadius
    default: return 0
    }
  }
}

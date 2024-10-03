import Foundation

extension Device {
  public var screenCornerRadiusPixels: Double {
    switch self {
    case .iPhone(let iPhoneModel):
      switch iPhoneModel {
      case .se2, .se3: 0
      case .xs, .xsMax, ._11Pro, ._11ProMax: 117
      case ._11, .xr: 124
      case ._12mini, ._13mini: 132
      case ._12, ._12Pro, ._13, ._13Pro, ._14: 141
      case ._12ProMax, ._13ProMax, ._14Plus: 159
      case ._14Pro, ._14ProMax, ._15, ._15Plus, ._15Pro, ._15ProMax, ._16, ._16Plus: 166
      case ._16Pro, ._16ProMax: 190
      case ._17, ._17Plus: 166
      case ._17Pro, ._17ProMax: 190
      case .unknown(let modelNumber): 0
      }
    case .iPad(let iPadModel):
      switch iPadModel {
      case .air4, .pro11Inch1, .pro11Inch2, .pro12Inch3, .pro12Inch4: 54
      default: 0
      }
    case .appleWatch(let model):
      switch model {
      case .series6_40mm, .seriesSE2_40mm: 84
      case .series6_44mm, .seriesSE2_44mm: 93
      case .series7_41mm, .series8_41mm, .series9_41mm: 111
      case .series7_45mm, .series8_45mm, .series9_45mm: 114
      case .ultra1, .ultra2: 114
      case .unknown: 111
      }
    case .simulator(let simulatedDevice): simulatedDevice.screenCornerRadiusPixels
    default: 0
    }
  }
  
  public var screenCornerRadius: Double {
    switch self {
    case .iPhone(let iPhoneModel):
      switch iPhoneModel {
      case .se2, .se3: 0
      case .xs, .xsMax, ._11Pro, ._11ProMax: 39
      case ._11, .xr: 41.5
      case ._12mini, ._13mini: 44
      case ._12, ._12Pro, ._13, ._13Pro, ._14: 47
      case ._12ProMax, ._13ProMax, ._14Plus: 53
      case ._14Pro, ._14ProMax, ._15, ._15Plus, ._15Pro, ._15ProMax, ._16, ._16Plus: 55 + 1/3
      case ._16Pro, ._16ProMax: 63 + 1/3
      case ._17, ._17Plus: 55 + 1/3
      case ._17Pro, ._17ProMax: 63 + 1/3
      case .unknown(let modelNumber): 0
      }
    case .iPad(let iPadModel):
      switch iPadModel {
      case .air4, .pro11Inch1, .pro11Inch2, .pro12Inch3, .pro12Inch4: 18
      default: 0
      }
    case .appleWatch(let model):
      switch model {
      case .series6_40mm, .seriesSE2_40mm: 28
      case .series6_44mm, .seriesSE2_44mm: 31
      case .series7_41mm, .series8_41mm, .series9_41mm: 37
      case .series7_45mm, .series8_45mm, .series9_45mm: 38
      case .ultra1, .ultra2: 38
      case .unknown: 37
      }
    case .simulator(let simulatedDevice): simulatedDevice.screenCornerRadius
    default: 0
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
      case ._17: true
      case ._17Plus: true
      case ._17Pro: true
      case ._17ProMax: true
      case .se2: false
      case .se3: false
      case .unknown: false
      }
    case .simulator(let simulatedDevice): simulatedDevice.hasDynamicIsland
    default: false
    }
  }
}

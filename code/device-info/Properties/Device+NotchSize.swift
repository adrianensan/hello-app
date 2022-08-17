import Foundation

extension Device {

  public var notchWidth: Double {
    switch self {
    case .iPhone(let iPhoneModel):
      switch iPhoneModel {
      case .x, .xs, .xsMax: return 209
      case ._11Pro, ._11ProMax: return 214
      case ._11, .xr: return 220
      case ._12mini: return 214
      case ._12, ._12Pro: return 214
      case ._12ProMax: return 214
      case ._13, ._13Pro, ._13ProMax: return 160
      case ._13mini: return 168
      default: return 0
      }
    case .simulator(let simulatedDevice): return simulatedDevice.notchWidth
    default: return 0
    }
  }
  
  public var notchHeight: Double {
    switch self {
    case .iPhone(let iPhoneModel):
      switch iPhoneModel {
      case .x, .xs, .xsMax, ._11Pro, ._11ProMax: return 28
      case .xr, ._11: return 29
      case ._12mini, ._12, ._12Pro,._12ProMax: return 32
      case ._13, ._13Pro, ._13ProMax: return 34
      case ._13mini: return 31
      default: return 0
      }
    case .simulator(let simulatedDevice): return simulatedDevice.notchHeight
    default: return 0
    }
  }
}

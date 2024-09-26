import Foundation

extension Device {
  public var processor: DeviceProcessor {
    switch self {
    case .iPhone(let iPhoneModel):
      switch iPhoneModel {
      case .xs, .xsMax, .xr: .a12
      case ._11, ._11Pro, ._11ProMax: .a13
      case ._12mini, ._12, ._12Pro, ._12ProMax: .a14
      case ._13mini, ._13, ._13Pro, ._13ProMax: .a15
      case ._14, ._14Plus, ._14Pro, ._14ProMax: .a16
      case ._15, ._15Plus: .a16
      case ._15Pro, ._15ProMax: .a17Pro
      case ._16, ._16Plus: .a18
      case ._16Pro, ._16ProMax: .a18Pro
      case ._17, ._17Plus: .a19
      case ._17Pro, ._17ProMax: .a19Pro
      case .se2: .a13
      case .se3: .a15
      case .unknown(let modelNumber): .a15
      }
    case .iPad(let iPadModel):
      switch iPadModel {
      case ._7: .a10
      case ._8: .a12
      case ._9: .a13
      case ._10: .a14
      case .air3: .a12
      case .air4: .a14
      case .air5: .m1
      case .air11Inch6, .air13Inch6: .m2
      case .mini5: .a12
      case .mini6: .a15
      case .pro11Inch1, .pro12Inch3: .a12x
      case .pro11Inch2, .pro12Inch4: .a12z
      case .pro11Inch3, .pro12Inch5: .m1
      case .pro11Inch4, .pro12Inch6: .m2
      case .pro11Inch5, .pro13Inch7: .m4
      case .unknown(let modelNumber): .m4
      }
    case .appleWatch(let appleWatchModel):
      switch appleWatchModel {
      case .series6_40mm, .series6_44mm: .s6
      case .seriesSE2_40mm, .seriesSE2_44mm: .s8
      case .series7_41mm, .series7_45mm: .s7
      case .series8_41mm, .series8_45mm: .s8
      case .series9_41mm, .series9_45mm: .s9
      case .ultra1: .s8
      case .ultra2: .s9
      case .unknown(let modelNumber): .s9
      }
    case .appleTV(let appleTVModel):
      switch appleTVModel {
      case .tv: .a8
      case .tv4K: .a10X
      case .tv4K2: .a12
      case .tv4K3: .a15
      case .unknown(let modelNumber): .a10
      }
    case .mac: .m4
    case .simulator(let device): device.processor
    case .unknown(let identifier): .a10
    }
  }
}

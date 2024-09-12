import Foundation

import HelloCore

public indirect enum Device: CustomStringConvertible, Equatable, Sendable {
  case iPhone(IPhoneModel)
  case iPad(IPadModel)
  case appleWatch(AppleWatchModel)
  case appleTV(AppleTVModel)
  case mac
  case simulator(device: Device)
  case unknown(identifier: String)
  
  public static let current = Device.infer(from: deviceModelIdentifier)
  
  public static var currentEffective: Device {
    switch current {
    case .simulator(let simulatedDevice): simulatedDevice
    default: current
    }
  }
  
  public var description: String {
    switch self {
    case .iPhone(let model): "iPhone \(model.description)"
    case .iPad(let model): "iPad \(model.description)"
    case .appleWatch(let model): "Apple Watch \(model.description)"
    case .appleTV(let model): "Apple TV \(model.description)"
    case .mac: "Mac"
    case .simulator(let simulatedDevice): "Simulator (\(simulatedDevice.description))"
    case .unknown(let identifier): "Unkown Device (\(identifier))"
    }
  }
  
  public var supportsTrueBlack: Bool {
    switch self {
    case .iPhone(let model):
      [.xs, .xsMax,
       ._11Pro, ._11ProMax, ._11,
       ._12mini, ._12, ._12Pro, ._12ProMax,
       ._13mini, ._13, ._13Pro, ._13ProMax,
       ._14, ._14Plus, ._14Pro, ._14ProMax,
       ._15, ._15Plus, ._15Pro, ._15ProMax].contains(model)
    case .appleWatch: true
    case .simulator(let simulatedDevice): simulatedDevice.supportsTrueBlack
    default: false
    }
  }
  
  public var supportsCellularConnections: Bool {
    switch self {
    case .iPhone: true
    case .simulator(let simulatedDevice): simulatedDevice.supportsCellularConnections
    default: false
    }
  }
  
  public enum BiometricsPopupLocation {
    case top
    case center
  }
  
  public var biometricsPopupLocation: BiometricsPopupLocation {
    switch self {
    case .iPhone(let model):
      [._14Pro, ._14ProMax, ._15, ._15Plus, ._15Pro, ._15ProMax].contains(model) ? .top : .center
    case .iPad: .center
    case .simulator(let simulatedDevice): simulatedDevice.biometricsPopupLocation
    default: .center
    }
  }
  
  public var appIconSize: Double {
    60
//    switch self {
//    case .iPhone(_), .iPod(_):
//      return 60
//    case .iPad(let model):
//      if [.pro12Inch1, .pro12Inch2, .pro12Inch3, .pro12Inch4].contains(model) {
//        return 83.5
//      } else {
//        return 76
//      }
//    default: return 60
//    }
  }
  
  public var tryBottomHeavy: Bool {
    switch self {
    case .iPhone: true
    case .simulator(let simulatedDevice): simulatedDevice.tryBottomHeavy
    default: false
    }
  }
  
  public var hasHomeButton: Bool {
    screenCornerRadius == 0
  }
  
  public var homeBarWidth: Double {
    switch self {
    case .iPhone(let iPhoneModel):
      switch iPhoneModel {
      case .xs, ._11Pro: 134
      case .xsMax, ._11ProMax: 148
      case ._11, .xr: 134
      case ._12mini, ._13mini: 120
      case ._12, ._12Pro, ._13, ._13Pro: 134
      case ._12ProMax, ._13ProMax: 152
      case ._14, ._14Pro, ._15, ._15Pro, ._16: 134
      case ._14ProMax, ._15ProMax: 152
      case ._16Pro: 134
      case ._16ProMax: 152
      case ._14Plus: 152
      case ._15Plus: 152
      case ._16Plus: 152
      case .se2: 0
      case .se3: 0
      case .unknown(modelNumber: let modelNumber): 0
      }
    case .iPad(let iPadModel):
      switch iPadModel {
      case .air4, .pro11Inch1, .pro11Inch2, .pro11Inch3,
          .pro12Inch3, .pro12Inch4, .pro12Inch5: 134
      default: 0
      }
    case .simulator(let simulatedDevice): simulatedDevice.homeBarWidth
    default: 0
    }
  }
  
  public var iconName: String {
    switch self {
    case .iPhone:
      hasDynamicIsland ? "iphone.gen3" :
      screenCornerRadius > 0 ? "iphone.gen2" : "iphone.gen1"
    case .iPad: screenCornerRadius > 0 ? "ipad.gen1" : "ipad.gen2"
    case .appleWatch: "applewatch"
    case .appleTV: "appletv"
    case .mac: "laptopcomputer"
    case .unknown: "airplayaudio"
    case .simulator(let simulatedDevice): simulatedDevice.iconName
    }
  }
  
  public static var deviceModelIdentifier: String {
//    size_t len = 0;
//    sysctlbyname("hw.model", NULL, &len, NULL, 0);
//    if (len) {
//      char *model = malloc(len*sizeof(char));
//      sysctlbyname("hw.model", model, &len, NULL, 0);
//      printf("%s\n", model);
//      free(model);
//    }
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier
  }
  
  static func infer(from id: String) -> Device {
    switch id {
    case hasPrefix(IPhoneModel.identifierPrefix):
      .iPhone(.inferFrom(modelNumber: id))
    case hasPrefix(IPadModel.identifierPrefix):
      .iPad(.inferFrom(modelNumber: id))
    case hasPrefix(AppleWatchModel.identifierPrefix):
      .appleWatch(.inferFrom(modelNumber: id))
    case hasPrefix(AppleTVModel.identifierPrefix):
      .appleTV(.inferFrom(modelNumber: id))
    case hasPrefix("arm64"), hasPrefix("x64_86"):
      if let simulatorDeviceModel = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
        .simulator(device: Device.infer(from: simulatorDeviceModel))
      } else {
        .mac
      }
    default:
      .unknown(identifier: id)
    }
  }
}

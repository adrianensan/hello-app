import Foundation

public enum DefaultsPersistenceSuite: Hashable, Sendable, CaseIterable {
  case standard
  case appGroup
  case helloShared
  case custom(String)
  
  public var id: String {
    switch self {
    case .standard: "standard"
    case .appGroup: "appGroup"
    case .helloShared: "hello"
    case .custom(let suite): suite
    }
  }
  
  public var name: String {
    switch self {
    case .standard: "Standard"
    case .appGroup: "App Group"
    case .helloShared: "Hello"
    case .custom(let suite): suite
    }
  }
  
  public static var allCases: [DefaultsPersistenceSuite] { [
    .standard,
    .appGroup,
    .helloShared,
  ]}
  
  public var userDefaults: UserDefaults? {
    switch self {
    case .standard:
      return .standard
    case .appGroup:
      if let appGroupDefaults = UserDefaults(suiteName: AppInfo.appGroup) {
        return appGroupDefaults
      } else {
        Log.fatal(context: "Persistence", "Failed to create UserDefaults for app group, please ensure \(AppInfo.appGroup) is added as an App Group")
        return nil
      }
    case .helloShared:
      if let helloDefaults = UserDefaults(suiteName: AppInfo.sharedHelloGroup) {
        return helloDefaults
      } else {
        Log.fatal(context: "Persistence", "Failed to create UserDefaults for share Hello, please ensure com.adrianensan.hello is added as an App Group")
        return nil
      }
    case .custom(let suiteName):
      if let helloDefaults = UserDefaults(suiteName: suiteName) {
        return  helloDefaults
      } else {
        Log.fatal(context: "Persistence", "Failed to create UserDefaults for \(suiteName)")
        return nil
      }
    }
  }
}

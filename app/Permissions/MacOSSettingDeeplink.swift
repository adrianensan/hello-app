import Foundation

public enum MacOSSettingDeeplink {
  case microphonePermissions
  case cameraPermissions
  case screenRecordingPermissions
  case notificationsPermissions
  
  public var url: URL {
    switch self {
    case .microphonePermissions: return URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!
    case .cameraPermissions: return URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")!
    case .screenRecordingPermissions: return URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
    case .notificationsPermissions: return URL(string: "x-apple.systempreferences:com.apple.preference.notifications?id=com.onlyforward.throw")!
    }
  }
}

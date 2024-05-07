import AVFoundation

#if os(iOS) || os(macOS)
@MainActor
@Observable
public class MicrophonePermissionsManager {
  
  public static var main = MicrophonePermissionsManager()
  
  public private(set) var permissionStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
  
  public func requestPermissionsIfNeeded() async -> Bool {
    if permissionStatus == .authorized {
      return true
    }
    return await AVCaptureDevice.requestAccess(for: .audio)
  }
}

@MainActor
@Observable
public class CameraPermissionsManager {
  
  public static var main = CameraPermissionsManager()
  
  public private(set) var permissionStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
  
  public func requestPermissionsIfNeeded() async -> Bool {
    if permissionStatus == .authorized {
      return true
    }
    return await AVCaptureDevice.requestAccess(for: .video)
  }
  
  public func refresh() {
  permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
  }
}
#endif

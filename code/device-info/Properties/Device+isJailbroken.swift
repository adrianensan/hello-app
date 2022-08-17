import Foundation

extension Device {
  
  #if os(iOS)
  fileprivate func containsSuspiciousApps() -> Bool {
    for path in suspiciousAppsPathToCheck {
      if FileManager.default.fileExists(atPath: path) {
        return true
      }
    }
    return false
  }
  
  fileprivate func isSuspiciousSystemPathsExists() -> Bool {
    for path in suspiciousSystemPathsToCheck {
      if FileManager.default.fileExists(atPath: path) {
        return true
      }
    }
    return false
  }
  
  fileprivate func canEditSystemFiles() -> Bool {
    let jailBreakText = "JailbreakVerification"
    do {
      try jailBreakText.write(toFile: jailBreakText, atomically: true, encoding: .utf8)
      return true
    } catch {
      return false
    }
  }
  
  fileprivate var suspiciousAppsPathToCheck: [String] {
    ["/Applications/Cydia.app",
     "/Applications/blackra1n.app",
     "/Applications/FakeCarrier.app",
     "/Applications/Icy.app",
     "/Applications/IntelliScreen.app",
     "/Applications/MxTube.app",
     "/Applications/RockApp.app",
     "/Applications/SBSettings.app",
     "/Applications/WinterBoard.app"
    ]
  }
  
  fileprivate var suspiciousSystemPathsToCheck: [String] {
    ["/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
     "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
     "/private/var/lib/apt",
     "/private/var/lib/apt/",
     "/private/var/lib/cydia",
     "/private/var/mobile/Library/SBSettings/Themes",
     "/private/var/stash",
     "/private/var/tmp/cydia.log",
     "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
     "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
     "/usr/bin/sshd",
     "/usr/libexec/sftp-server",
     "/usr/sbin/sshd",
     "/etc/apt",
     "/bin/bash",
     "/Library/MobileSubstrate/MobileSubstrate.dylib"
    ]
  }
  #endif
  
  public var isJailbroken: Bool {
    #if os(iOS)
    if case .simulator = self {
      return false
    } else {
      return containsSuspiciousApps()
      || isSuspiciousSystemPathsExists()
      || canEditSystemFiles()
    }
    #else
    false
    #endif
  }
}

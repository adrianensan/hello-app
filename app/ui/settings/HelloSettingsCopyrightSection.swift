#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct HelloSettingsCopyrightSection: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  
  @Persistent(.isDeveloper) private var isDeveloper
  @Persistent(.isFakeDeveloper) private var isFakeDeveloper
  
  @NonObservedState private var unlockDevModeClickCount: Int = 0
  @NonObservedState private var unlockDevModeLastClick: TimeInterval = 0
  
  public var body: some View {
    VStack(spacing: 0) {
      Text("App Version: \(AppInfo.version)\(AppInfo.isTestBuild ? " (\(AppInfo.build))" : "")")
        .font(.system(size: 15, weight: .bold))
      
      Text(Device.current.description + ", " + OSInfo.description)
        .font(.system(size: 11, weight: .regular))
        .padding(.bottom, 6)
      
      HelloLogo()
        .frame(width: 80, height: 80)
        .foregroundStyle(theme.foreground.primary.style)
        .opacity(0.16)
        .padding(.top, 32)
        .padding(.bottom, 4)
        .clickable()
        .onTapGesture {
          if epochTime - unlockDevModeLastClick < 1 {
            unlockDevModeClickCount += 1
            if unlockDevModeClickCount >= 20 {
              if !isFakeDeveloper && !isDeveloper {
                windowModel.show(alert: HelloAlertConfig(
                  title: "Enable Developer Mode",
                  message: "This will reveal access to logs, debug options, file management and more.\n\nWarning, you will easily be able to mess up the app if you delete the wrong files.",
                  firstButton: .cancel,
                  secondButton: .init(name: "Enable", action: { isFakeDeveloper = true }, isDestructive: true)))
              } else {
                windowModel.show(alert: HelloAlertConfig(
                  title: "Developer Mode Enabled",
                  message: #"Access developer options through the "Developer" settings menu"#,
                  firstButton: .ok))
              }
            }
            Haptics.shared.feedback(intensity: Float(unlockDevModeClickCount) / 20)
          } else {
            unlockDevModeClickCount = 1
          }
          unlockDevModeLastClick = epochTime
        }
      
      Text("© 2024 Adrian Ensan")
        .font(.system(size: 11, weight: .regular))
        .fixedSize()
      
    }.foregroundStyle(theme.foreground.tertiary.style)
  }
}
#endif

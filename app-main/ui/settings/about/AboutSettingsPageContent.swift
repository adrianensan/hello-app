#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct AboutSettingsPageContent: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeArea
  @Environment(HelloPagerModel.self) private var pagerModel
  
  @Persistent(.deviceID) private var deviceID
  @Persistent(.firstDateLaunched) private var firstDateLaunched
  
  var body: some View {
    VStack(spacing: 24) {
      HelloSection(title: "APP") {
        let action: MenuHelloButtonAction = .showMenu { [.copy(string: AppInfo.displayName)] }
        HelloButton(clickStyle: .highlight, tapAndLongPressAction: action) {
          HelloNavigationRow(name: "App Name") { Text(AppInfo.displayName) }
        }
        
        HelloButton(clickStyle: .highlight, tapAndLongPressAction: .showMenu { @MainActor in [.copy(string: AppInfo.fullVersionString)] }) {
          HelloNavigationRow(name: "App Version") { Text(AppInfo.fullVersionString) }
        }
        
        HelloButton(clickStyle: .highlight, tapAndLongPressAction: .showMenu { @MainActor in [.copy(string: AppInfo.rootBundleID)] }) {
          HelloNavigationRow(name: "Bundle ID") { Text(AppInfo.rootBundleID) }
        }
        
        let firstDateLaunchedString = firstDateLaunched.absoluteDateAndTimeString
        HelloButton(clickStyle: .highlight, tapAndLongPressAction: .showMenu { @MainActor in [.copy(string: firstDateLaunchedString)] }) {
          HelloNavigationRow(name: "Install Date") { Text(firstDateLaunchedString) }
        }
      }
      
      HelloSection(title: "DEVICE") {
        let deviceString = Device.current.description
        HelloButton(clickStyle: .highlight, tapAndLongPressAction: .showMenu { @MainActor in [.copy(string: deviceString)] }) {
          HelloNavigationRow(name: "Device Name") { Text(deviceString) }
        }
        
        let deviceModel = Device.deviceModelIdentifier
        HelloButton(clickStyle: .highlight, tapAndLongPressAction: .showMenu { @MainActor in [.copy(string: deviceModel)] }) {
          HelloNavigationRow(name: "Device Model") { Text(deviceModel) }
        }
        
        let processor = Device.current.processor.name
        HelloButton(clickStyle: .highlight, tapAndLongPressAction: .showMenu { @MainActor in [.copy(string: processor)] }) {
          HelloNavigationRow(name: "Chip") { Text(processor) }
        }
        
        let osString = OSInfo.description
        HelloButton(clickStyle: .highlight, tapAndLongPressAction: .showMenu { @MainActor in [.copy(string: osString)] }) {
          HelloNavigationRow(name: "OS") { Text(osString) }
        }
        
        HelloButton(clickStyle: .highlight, tapAndLongPressAction: .showMenu { @MainActor in [.copy(string: deviceID)] }) {
          HelloNavigationRow(name: "Device ID") { Text(deviceID) }
        }
      }
      
      HelloSection {
        HelloButton(clickStyle: .highlight, action: { pagerModel.push { TechnicalDetailsSettingsPage() } }) {
          HelloNavigationRow(name: "Technical Details", actionIcon: .arrow)
        }
        HelloButton(clickStyle: .highlight, action: { pagerModel.push { PrivacyPolicySettingsPage() } }) {
          HelloNavigationRow(name: "Privacy Policy", actionIcon: .arrow)
        }
      }
      
      Text(AppInfo.copyright)
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(theme.foreground.tertiary.style)
    }
  }
}
#endif

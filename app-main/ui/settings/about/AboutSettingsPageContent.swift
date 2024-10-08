#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct AboutSettingsPageContent: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeArea
  @Environment(PagerModel.self) private var pagerModel
  
  @Persistent(.deviceID) private var deviceID
  @Persistent(.firstDateLaunched) private var firstDateLaunched
  
  var body: some View {
    VStack(spacing: 24) {
      HelloSection(title: "APP") {
        HelloMenuButton(items: { [.copy(string: AppInfo.displayName)] }) {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 0) {
              Text("App Name")
                .font(.system(size: 16, weight: .regular))
              
              Spacer(minLength: 0)
              
              Text(AppInfo.displayName)
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
        
        HelloMenuButton(items: { [.copy(string: AppInfo.fullVersionString)] }) {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 0) {
              Text("App Version")
                .font(.system(size: 16, weight: .regular))
              
              Spacer(minLength: 0)
              
              Text(AppInfo.fullVersionString)
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
        
        HelloMenuButton(items: { [.copy(string: AppInfo.rootBundleID)] }) {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 0) {
              Text("Bundle ID")
                .font(.system(size: 16, weight: .regular))
              
              Spacer(minLength: 0)
              
              Text(AppInfo.rootBundleID)
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
        
        let firstDateLaunchedString = firstDateLaunched.absoluteDateAndTimeString
        HelloMenuButton(items: { [.copy(string: firstDateLaunchedString)] }) {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 0) {
              Text("Install Date")
                .font(.system(size: 16, weight: .regular))
              
              Spacer(minLength: 0)
              
              Text(firstDateLaunchedString)
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
      }
      
      HelloSection(title: "DEVICE") {
        let deviceString = Device.current.description
        HelloMenuButton(items: { [.copy(string: deviceString)] }) {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 0) {
              Text("Device Name")
                .font(.system(size: 16, weight: .regular))
              
              Spacer(minLength: 0)
              
              Text(deviceString)
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
        
        let deviceModel = Device.deviceModelIdentifier
        HelloMenuButton(items: { [.copy(string: deviceModel)] }) {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 0) {
              Text("Device Model")
                .font(.system(size: 16, weight: .regular))
              
              Spacer(minLength: 0)
              
              Text(deviceModel)
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
        
        let processor = Device.current.processor.name
        HelloMenuButton(items: { [.copy(string: processor)] }) {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 0) {
              Text("Chip")
                .font(.system(size: 16, weight: .regular))
              
              Spacer(minLength: 0)
              
              Text(processor)
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
        
        let osString = OSInfo.description
        HelloMenuButton(items: { [.copy(string: osString)] }) {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 0) {
              Text("OS")
                .font(.system(size: 16, weight: .regular))
              
              Spacer(minLength: 0)
              
              Text(osString)
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
        
        HelloMenuButton(items: { [.copy(string: deviceID)] }) {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 0) {
              Text("Device ID")
                .font(.system(size: 16, weight: .regular))
              
              Spacer(minLength: 0)
              
              Text(deviceID)
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
      }
      
      
      HelloSection {
        HelloButton(clickStyle: .highlight, action: { pagerModel.push { TechnicalDetailsSettingsPage() } }) {
          HelloNavigationRow(icon: nil, name: "Technical Details", actionIcon: .arrow)
        }
        HelloButton(clickStyle: .highlight, action: { pagerModel.push { PrivacyPolicySettingsPage() } }) {
          HelloNavigationRow(icon: nil, name: "Privacy Policy", actionIcon: .arrow)
        }
      }
      
      Text("© 2024 Adrian Ensan")
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(theme.foreground.tertiary.style)
    }
  }
}
#endif

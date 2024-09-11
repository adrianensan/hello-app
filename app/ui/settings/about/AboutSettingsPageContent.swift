#if os(iOS)
import SwiftUI

import HelloCore

struct AboutSettingsPageContent: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeArea
  @Environment(PagerModel.self) private var pagerModel
  
  @Persistent(.deviceID) private var deviceID
  @Persistent(.firstDateLaunched) private var firstDateLaunched
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HelloSection {
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
        
        let appVersionString = "\(AppInfo.version) (\(AppInfo.build))"
        HelloMenuButton(items: { [.copy(string: appVersionString)] }) {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 0) {
              Text("App Version")
                .font(.system(size: 16, weight: .regular))
              
              Spacer(minLength: 0)
              
              Text(appVersionString)
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
        
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
        
        HelloSectionItem(leadingPadding: false) {
          HStack(spacing: 0) {
            Text("Copyright")
              .font(.system(size: 16, weight: .regular))
            
            Spacer(minLength: 0)
            
            Text("© 2024 Adrian Ensan")
              .font(.system(size: 16, weight: .regular))
          }
        }
      }
      
      HelloSection {
        HelloButton(clickStyle: .highlight, action: { pagerModel.push { TechnicalDetailsSettingsPage() } }) {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 0) {
              Text("Technical Details")
                .font(.system(size: 16, weight: .regular))
              
              Spacer(minLength: 0)
              
              Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
        HelloButton(clickStyle: .highlight, action: { pagerModel.push { PrivacyPolicySettingsPage() } }) {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 0) {
              Text("Privacy Policy")
                .font(.system(size: 16, weight: .regular))
              
              Spacer(minLength: 0)
              
              Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
      }
    }
  }
}
#endif

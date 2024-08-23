import SwiftUI

import HelloCore

public struct AppStoreReviewSettingsItem: View {
  
  @Environment(\.openURL) private var openURL
  
  private let appName: String
  private let appID: String
  
  public init(appName: String, appID: String) {
    self.appName = appName
    self.appID = appID
  }
  
  public var body: some View {
    if let appStoreReviewURL = URL(string: "https://apps.apple.com/app/\(appName)/id\(appID)?action=write-review&mt=8") {
      HelloButton(clickStyle: .highlight, haptics: .click, action: {
        openURL(appStoreReviewURL)
      }) {
        HelloSectionItem {
          HStack(spacing: 4) {
            Image(systemName: "heart")
              .font(.system(size: 20, weight: .regular, design: .rounded))
              .frame(width: 32, height: 32)
            Text("Review in App Store")
              .font(.system(size: 16, weight: .regular, design: .rounded))
              .fixedSize()
            Spacer(minLength: 16)
            Image(systemName: "arrow.up.forward.app")
              .font(.system(size: 16, weight: .regular, design: .rounded))
          }
        }
      }
    }
  }
}

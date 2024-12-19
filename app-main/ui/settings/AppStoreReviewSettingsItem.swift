import SwiftUI

import HelloCore
import HelloApp

public struct AppStoreReviewSettingsItem: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.openURL) private var openURL
  
  private let appName: String
  private let appID: String
  
  public init(appName: String, appID: String) {
    self.appName = appName
    self.appID = appID
  }
  
  public var body: some View {
    if let appStoreReviewURL = URL(string: "\(AppStoreURLGenerator.url(for: appID))?action=write-review&mt=8") {
      HelloButton(clickStyle: .highlight, action: {
        openURL(appStoreReviewURL)
      }) {
        HelloNavigationRow(icon: "heart", name: "Write Review in App Store", actionIcon: .openExternal)
      }
    }
  }
}

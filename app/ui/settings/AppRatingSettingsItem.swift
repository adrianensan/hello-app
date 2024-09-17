#if os(iOS)
import SwiftUI

import HelloCore

public struct AppRatingSettingsItem: View {
  
  @Environment(\.requestReview) private var requestReview
  
  @Persistent(.lastDateRatingClicked) private var lastDateRatingClicked
  
  public init() {}
  
  public var body: some View {
    if !AppInfo.isTestBuild && lastDateRatingClicked.addingTimeInterval(4 * 30 * .secondsInDay) < .now {
      HelloButton(clickStyle: .highlight, haptics: .click, action: {
        requestReview()
        withAnimation(.easeInOut(duration: 0.2)) {
          lastDateRatingClicked = .now
        }
      }) {
        HelloSectionItem {
          HStack(spacing: 4) {
            Image(systemName: "star")
              .font(.system(size: 20, weight: .regular))
              .frame(width: 32, height: 32)
            Text("Rate \(AppInfo.displayName)")
              .font(.system(size: 16, weight: .regular))
              .fixedSize()
            Spacer(minLength: 16)
            ForEach(0..<5) { _ in
              Image(systemName: "star")
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
      }
    }
  }
}
#endif

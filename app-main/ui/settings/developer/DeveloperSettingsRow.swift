#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

public struct DeveloperSettingsRow<AdditionalContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(PagerModel.self) private var pagerModel
  
  @ViewBuilder private var additionalContent: @MainActor () -> AdditionalContent
  
  public init(@ViewBuilder additionalContent: @escaping @MainActor () -> AdditionalContent) {
    self.additionalContent = additionalContent
  }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(name: "Developer") { DeveloperSettingsPage(additionalContent: additionalContent) }
    }) {
      HelloNavigationRow(icon: "hammer", name: "Developer", actionIcon: .arrow)
    }
  }
}

public extension DeveloperSettingsRow where AdditionalContent == EmptyView {
  public init() {
    self.additionalContent = { EmptyView() }
  }
}
#endif

#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

public struct DeveloperSettingsRow<AdditionalContent: View>: View {
  
  @Environment(PagerModel.self) private var pagerModel
  
  @ViewBuilder private var additionalContent: @MainActor () -> AdditionalContent
  
  public init(@ViewBuilder additionalContent: @escaping @MainActor () -> AdditionalContent) {
    self.additionalContent = additionalContent
  }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(name: "Developer") { DeveloperSettingsPage(additionalContent: additionalContent) }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "hammer")
            .font(.system(size: 20, weight: .regular, design: .rounded))
            .frame(width: 32, height: 32)
          
          Text("Developer")
            .font(.system(size: 16, weight: .regular, design: .rounded))
          Spacer(minLength: 0)
          Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .regular, design: .rounded))
        }
      }
    }
  }
}

public extension DeveloperSettingsRow where AdditionalContent == EmptyView {
  public init() {
    self.additionalContent = { EmptyView() }
  }
}
#endif

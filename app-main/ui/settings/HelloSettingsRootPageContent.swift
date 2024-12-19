#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct HelloSettingsRootPageContent<Content: View, AdditionalDeveloperContent: View>: View {
  
  @Environment(\.hasAppeared) private var hasAppeared
  
  @Persistent(.isDeveloper) private var isDeveloper
  @Persistent(.isFakeDeveloper) private var isFakeDeveloper
  
  @ViewBuilder private var content: @MainActor () -> Content
  @ViewBuilder private var additionalDeveloperContent: @MainActor () -> AdditionalDeveloperContent
  
  public init(@ViewBuilder content: @escaping @MainActor () -> Content,
              @ViewBuilder additionalDeveloperContent: @escaping @MainActor () -> AdditionalDeveloperContent) {
    self.content = content
    self.additionalDeveloperContent = additionalDeveloperContent
  }
  
  public var body: some View {
    VStack(spacing: 24) {
      content()
      
      HelloSection {
        AboutSettingsRow()
        if isDeveloper || isFakeDeveloper {
          DeveloperSettingsRow(additionalContent: additionalDeveloperContent)
        }
      }
      
      //      OtherHelloAppsView()
      
      HelloSettingsCopyrightSection()
    }
  }
}

public extension HelloSettingsRootPageContent where AdditionalDeveloperContent == EmptyView {
  init(@ViewBuilder content: @escaping @MainActor () -> Content) {
    self.content = content
    self.additionalDeveloperContent = { EmptyView() }
  }
}
#endif

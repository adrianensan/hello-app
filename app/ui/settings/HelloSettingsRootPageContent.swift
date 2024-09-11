#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct HelloSettingsRootPageContent<Content: View>: View {
  
  @Persistent(.isDeveloper) private var isDeveloper
  @Persistent(.isFakeDeveloper) private var isFakeDeveloper
  
  @ViewBuilder private var content: @MainActor () -> Content
  
  public init(@ViewBuilder content: @escaping @MainActor () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    VStack(spacing: 24) {
      content()
      
      HelloSection {
        if isDeveloper || isFakeDeveloper {
          DeveloperSettingsRow()
        }
        AboutSettingsRow()
      }
      
//      OtherHelloAppsView()
      
      HelloSettingsCopyrightSection()
    }
  }
}
#endif

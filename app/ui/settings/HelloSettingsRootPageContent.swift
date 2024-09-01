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
    VStack(spacing: 32) {
      content()
      
      if isDeveloper || isFakeDeveloper {
        HelloSection {
          DeveloperSettingsRow()
        }
      }
      
      HelloSettingsCopyrightSection()
        .padding(.bottom, 16)
    }
  }
}
#endif

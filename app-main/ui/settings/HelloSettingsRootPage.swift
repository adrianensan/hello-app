#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct HelloSettingsRootPage<Content: View>: View {
  
  @ViewBuilder private var content: @MainActor () -> Content
  
  public init(@ViewBuilder content: @escaping @MainActor () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    NavigationPage(title: "Settings") {
      HelloSettingsRootPageContent(content: content)
    }
  }
}
#endif

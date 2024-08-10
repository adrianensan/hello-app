#if os(iOS)
import SwiftUI

public struct NavigationPageBarScrolling<NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloScrollModel.self) private var scrollModel
  
  let title: String?
  @ViewBuilder let navBarContent: @MainActor () -> NavBarContent
  
  public var body: some View {
    NavigationPageBar(title: title, navBarContent: navBarContent)
      .opacity(scrollModel.hasScrolled ? 1 : 0)
  }
}
#endif

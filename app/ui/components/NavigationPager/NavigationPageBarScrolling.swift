#if os(iOS)
import SwiftUI

public struct NavigationPageBarScrolling<TitleContent: View, NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloScrollModel.self) private var scrollModel
  
  @ViewBuilder let titleContent: @MainActor () -> TitleContent
  @ViewBuilder let navBarContent: @MainActor () -> NavBarContent
  
  public var body: some View {
    NavigationPageBar(titleContent: titleContent, navBarContent: navBarContent)
      .opacity(scrollModel.hasScrolled ? 1 : 0)
  }
}
#endif

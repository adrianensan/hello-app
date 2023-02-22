import SwiftUI

import HelloCore

public struct HelloAppRootView<Content: View>: View {
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  @EnvironmentObject var uiProperties: UIProperties
  
  @ObservedObject var themeManager: ActiveThemeManager = .main
  
  @State var showHelloModal: Bool = false//Hello.isFirstLaunch
  
  var content: Content
  
  public init(_ content: Content) {
    self.content = content
  }
  
  var currentTheme: HelloTheme {
    colorScheme == .dark
    ? themeManager.darkTHeme
    : themeManager.lightTHeme
  }
  
  public var body: some View {
    ZStack {
#if os(iOS)
      ZStack {
        content
          .compositingGroup()
          .frame(width: uiProperties.size.width, height: uiProperties.size.height)
      }
#else
      ZStack {
        content
      }
#endif
    }.frame(width: uiProperties.size.width, height: uiProperties.size.height)
      .environment(\.theme, HelloSwiftUITheme(theme: .init(theme: currentTheme)))
      .animation(.easeInOut(duration: 0.2), value: currentTheme.id)
  }
}

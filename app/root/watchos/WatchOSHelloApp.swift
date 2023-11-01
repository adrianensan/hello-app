#if os(watchOS)
import SwiftUI

import HelloCore

open class HelloApp: App {
  
//  @WKExtensionDelegateAdaptor(HelloWatchExtensionDelegate.self) var extensionDelegate
  
  open var rootView: AnyView { AnyView(Color.clear) }
  
  required public init() {
//    Hello.persistence = persistence
//    ButtonHaptics.isEnabled = { Hello.persistence.hapticsLevel != .off }
  }
  
  public var body: some Scene {
    WindowGroup {
      HelloWatchRootView {
        HelloAppRootView {
          rootView
        }
      }
    }
  }
  
  public struct HelloAppRootView<Content: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.windowFrame) var windowFrame
    
//    @ObservedObject var themeObservable: ThemeObservable = .shared
//    @ObservedObject var uiPrefs: UIPrefsObservable = .shared
//    @ObservedObject var settingsModel: SettingsModel = .main
//    @ObservedObject var alertModel: HelloAlterModel = .main
    
    @State var showHelloModal: Bool = false//Hello.isFirstLaunch
    
    var content: Content
    
    public init(@ViewBuilder content: () -> Content) {
      self.content = content()
    }
    
    var helloTheme: HelloTheme {
      colorScheme == .dark
      ? .dark
      : .light
    }
    
    public var body: some View {
      content
        .frame(width: windowFrame.width, height: windowFrame.height)
        .environment(\.theme, HelloSwiftUITheme(theme: helloTheme))
    }
  }
}
#endif

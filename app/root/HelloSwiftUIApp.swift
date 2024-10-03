#if os(watchOS)
import SwiftUI

struct HelloSwiftUIWatchOSApp: App {
  
  @WKApplicationDelegateAdaptor(HelloAppDelegate.self) private var appDelegate
  
  var body: some Scene {
    WindowGroup {
      helloApplication.view()
        .environment(\.windowFrame, WKInterfaceDevice.current().screenBounds)
        .environment(\.viewFrame, WKInterfaceDevice.current().screenBounds)
        .environment(\.safeArea, EdgeInsets(WKApplication.shared().rootInterfaceController?.contentSafeAreaInsets ?? UIEdgeInsets()))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
  }
}
#endif

//struct HelloSwiftUIScene: Scene {
//  var body: some Scene {
//
//  }
//}



#if os(watchOS)
import WatchKit

class HelloAppDelegate: NSObject, WKApplicationDelegate {
  func applicationDidFinishLaunching() {
    print("hello")
  }
}
#endif

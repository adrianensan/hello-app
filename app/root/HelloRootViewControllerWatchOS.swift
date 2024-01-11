#if os(watchOS)
import WatchKit
import SwiftUI

class HelloRootViewController: WKHostingController<AnyView> {
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    // becomeCurrentPage()
    
    // Configure interface objects here.
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
  override var body: AnyView { helloApplication.view() }
}
#endif

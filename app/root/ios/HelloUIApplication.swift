#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit

public class HelloUIApplication: UIApplication {
  public override func sendEvent(_ event: UIEvent) {
    super.sendEvent(event)
    
    if event.allTouches?.contains(where: { $0.phase == .began }) == true {
      helloApplication.openUserInteraction()
    }
  }
}
#endif

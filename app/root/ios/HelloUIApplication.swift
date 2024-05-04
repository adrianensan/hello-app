#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit

public struct HelloTouch: Identifiable, Sendable {
  public var id: Int
  public var location: CGPoint
}

public class HelloUIApplication: UIApplication {
  
  private var activeTouches: [HelloTouch] = []
  
  public override func sendEvent(_ event: UIEvent) {
    super.sendEvent(event)
    
    for touch in event.allTouches ?? [] {
      switch touch.phase {
      case .ended, .cancelled:
        activeTouches.removeAll { $0.id == touch.hash }
      default:
        if let index = activeTouches.firstIndex(where: { touch.hash == $0.id }) {
          activeTouches[index] = HelloTouch(id: touch.hash, location: touch.location(in: nil))
        } else {
          activeTouches.append(HelloTouch(id: touch.hash, location: touch.location(in: nil)))
        }
      }
    }
    
    let allTouchIDs = (event.allTouches ?? []).map { $0.hash }
    activeTouches.removeAll { !allTouchIDs.contains($0.id) }
    
    helloApplication.touchesUpdateInternal(to: activeTouches)
  }
}
#endif

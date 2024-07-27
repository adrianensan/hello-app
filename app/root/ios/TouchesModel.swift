#if os(iOS)
import Foundation

@MainActor
@Observable
public class TouchesModel {
  
  public static let main = TouchesModel()
  
  public var isTouching: Bool { !activeTouches.isEmpty }
  
  var activeTouches: [HelloTouch] = []
  
  var hasScrolledDuringTouch: Bool = false
  
  private init() {}
}
#endif

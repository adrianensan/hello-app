#if os(iOS)
import Foundation

@MainActor
@Observable
class TouchesModel {
  
  static let main = TouchesModel()
  
  var activeTouches: [HelloTouch] = []
}
#endif

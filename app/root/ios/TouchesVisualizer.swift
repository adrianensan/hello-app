#if os(iOS)
import SwiftUI

@MainActor
struct TouchesVisualizer: View {
  
  let model: TouchesModel = .main
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      ForEach(model.activeTouches) { touch in
        Circle()
          .fill(Color(red: 0.72, green: 0.72, blue: 0.72).opacity(0.36))
          .frame(width: 44, height: 44)
          .frame(width: 1, height: 1)
          .offset(x: touch.location.x, y: touch.location.y)
      }
    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}
#endif

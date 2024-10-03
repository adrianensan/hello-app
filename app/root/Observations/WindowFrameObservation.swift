import SwiftUI

import HelloCore

struct WindowFrameObservationViewModifier: ViewModifier {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(UIProperties.self) private var uiProperties
  
  func body(content: Content) -> some View {
    content
      .environment(\.windowFrame, CGRect(origin: .zero, size: uiProperties.size))
      .environment(\.viewFrame, CGRect(origin: .zero, size: uiProperties.size))
      .environment(\.physicalScale, windowModel.physicalPixelScale)
      .environment(\.pixelsPerPoint, windowModel.physicalPixelsPerPoint)
      .if(uiProperties.size == windowModel.pointSize) {
        let shape = AnyInsettableShape(.rect(cornerRadius: Device.current.screenCornerRadiusPixels / windowModel.physicalPixelsPerPoint))
        $0
          .clipShape(shape)
          .background(Color.black)
          .environment(\.viewShape, shape)
          .environment(\.pageShape, AnyInsettableShape(.rect(
            cornerRadii: RectangleCornerRadii(
              topLeading: Device.current.screenCornerRadiusPixels / windowModel.physicalPixelsPerPoint,
              bottomLeading: Device.current.screenCornerRadiusPixels / windowModel.physicalPixelsPerPoint,
              bottomTrailing: 0,
              topTrailing: 0))))
      }
  }
}

@MainActor
public extension View {
  func observeWindowFrame() -> some View {
    modifier(WindowFrameObservationViewModifier())
  }
}

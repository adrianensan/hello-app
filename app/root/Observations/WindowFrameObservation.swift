import SwiftUI

import HelloCore

fileprivate struct WindowFrameObservationViewModifier: ViewModifier {
  
  @Environment(\.windowCornerRadius) private var windowCornerRadius
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(UIProperties.self) private var uiProperties
  
  private var debugModel: DebugModel = .main
  
  fileprivate func body(content: Content) -> some View {
    let isFullscreen = uiProperties.size == windowModel.pointSize
    let isFullscreenWidth = uiProperties.size.width == windowModel.pointSize.width
    let screenCornerRaidusPoints = Device.current.screenCornerRadiusPixels / windowModel.physicalPixelsPerPoint
    let shape: AnyInsettableShape = debugModel.disableMasking ? .rect : .rect(
      cornerRadii: RectangleCornerRadii(
        topLeading: isFullscreen ? screenCornerRaidusPoints : windowCornerRadius,
        bottomLeading: isFullscreenWidth ? screenCornerRaidusPoints : windowCornerRadius,
        bottomTrailing: isFullscreenWidth ? screenCornerRaidusPoints : windowCornerRadius,
        topTrailing: isFullscreen ? screenCornerRaidusPoints : windowCornerRadius))
    content
      .environment(\.windowFrame, CGRect(origin: .zero, size: uiProperties.size))
      .environment(\.viewFrame, CGRect(origin: .zero, size: uiProperties.size))
      .environment(\.physicalScale, windowModel.physicalPixelScale)
      .environment(\.pixelsPerPoint, windowModel.physicalPixelsPerPoint)
      .clipShape(shape)
      .background(Color.black)
      .environment(\.viewShape, shape)
      .environment(\.pageShape, debugModel.disableMasking ? .rect : .rect(
        cornerRadii: RectangleCornerRadii(
          topLeading: isFullscreen ? screenCornerRaidusPoints : windowCornerRadius,
          bottomLeading: isFullscreenWidth ? screenCornerRaidusPoints : windowCornerRadius,
          bottomTrailing: windowCornerRadius,
          topTrailing: windowCornerRadius)))
  }
}

@MainActor
public extension View {
  func observeWindowFrame() -> some View {
    modifier(WindowFrameObservationViewModifier())
  }
}

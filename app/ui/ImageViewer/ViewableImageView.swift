#if os(iOS)
import SwiftUI

import HelloCore

public struct ViewableImageView: View {
  
  private class NonObserved {
    var imageFrame: CGRect?
  }

  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel

  @State private var nonObserved = NonObserved()
  @State private var isOpened = false
  
  private var image: NativeImage

  public init(image: NativeImage) {
    self.image = image
  }

  public var body: some View {
    Image(nativeImage: image)
      .resizable()
      .interpolation(.high)
      .antialiased(true)
      .opacity(isOpened ? 0 : 1)
      .readGeometry {
        let frame = $0.frame(in: .global)
        nonObserved.imageFrame = frame
      }.onTapGesture {
        windowModel.showPopup(ImageViewer(image: image, originalFrame: nonObserved.imageFrame))
        isOpened = true
        ButtonHaptics.buttonFeedback()
      }
//      .onChange(of: windowModel.popupView == nil) {
//        if $0 && isOpened {
//          isOpened = false
//        }
//      }
  }
}
#endif

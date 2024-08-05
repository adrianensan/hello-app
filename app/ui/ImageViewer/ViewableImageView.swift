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
  
  private let imageOptions: [HelloImageOption]
  private let imageModels: [HelloImageModel]
  private let resizeMode: ContentMode
  private let allowViewing: Bool
  private let cornerRadius: CGFloat
  
  public init(_ source: HelloImageSource,
              variant: HelloImageVariant = .original,
              resizeMode: ContentMode = .fit,
              allowViewing: Bool = true,
              cornerRadius: CGFloat = 0) {
    imageOptions = [HelloImageOption(imageSource: source, variant: variant)]
    imageModels = [.model(for: source, variant: variant)]
    self.resizeMode = resizeMode
    self.allowViewing = allowViewing
    self.cornerRadius = cornerRadius
  }
  
  public init(options: [HelloImageOption],
              resizeMode: ContentMode = .fit,
              allowViewing: Bool = true,
              cornerRadius: CGFloat = 0) {
    imageOptions = options
    imageModels = options.map { .model(for: $0.imageSource, variant: $0.variant) }
    self.resizeMode = resizeMode
    self.allowViewing = allowViewing
    self.cornerRadius = cornerRadius
  }
  
  private var model: HelloImageModel? {
    imageModels.first { $0.image != nil }
  }

  public var body: some View {
    HelloImageView(options: imageOptions, resizeMode: resizeMode)
      .opacity(isOpened ? 0 : 1)
      .animation(nil, value: isOpened)
      .readGeometry {
        let frame = $0.frame(in: .global)
        nonObserved.imageFrame = frame
      }
      .simultaneousGesture(TapGesture()
        .onEnded{ _ in
          guard allowViewing else { return }
          var fullImageOptions: [HelloImageOption] = []
          for imageOption in imageOptions {
            if imageOption.variant != .original {
              fullImageOptions.append(HelloImageOption(imageSource: imageOption.imageSource, variant: .original))
            }
            fullImageOptions.append(imageOption)
          }
          
          windowModel.showPopup(onDismiss: {
            Task {
              try? await Task.sleep(seconds: 0.4)
              isOpened = false
            }
          }) {
            ImageViewer(options: fullImageOptions, originalFrame: nonObserved.imageFrame, cornerRadius: cornerRadius)
          }
          isOpened = true
          ButtonHaptics.buttonFeedback()
        })
//      .onChange(of: windowModel.popupView == nil) {
//        if $0 && isOpened {
//          isOpened = false
//        }
//      }
  }
}
#endif

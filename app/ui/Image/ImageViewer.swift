#if os(iOS)
import SwiftUI

import HelloCore

public struct ImageViewer: View {
  
  @MainActor
  @Observable
  class ImageViewModel {
    var dismissProgress: CGFloat?
  }
  
  public struct ImageViewerCloseButton: View {
    
    @Environment(ImageViewModel.self) private var imageViewModel
    var onDismiss: @MainActor () -> Void
    
    public var body: some View {
      HelloCloseButton(onDismiss: onDismiss)
        .offset(y: 20 * (imageViewModel.dismissProgress ?? 0))
        .environment(\.dismissProgress, imageViewModel.dismissProgress)
        .environment(\.theme, .init(theme: .helloDark))
        .environment(\.colorScheme, .dark)
        .environment(\.needsBlur, true)
    }
  }
  
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.safeArea) private var safeAreaInsets
  @Environment(\.contentShape) private var contentShape
  @Environment(\.popupID) private var viewID
  @Environment(HelloWindowModel.self) private var windowModel
  
  @State private var model = ImageViewModel()
  @State private var dismissVelocity: CGPoint?

  @State private var originalFrame: CGRect?
  
  private let imageOptions: [HelloImageOption]
  private var originalFrameSaved: CGRect?
  private var cornerRadius: CGFloat
  
  public init(options: [HelloImageOption],
              resizeMode: ContentMode = .fit,
              originalFrame: CGRect?,
              cornerRadius: CGFloat) {
    imageOptions = options
    self.originalFrameSaved = originalFrame
    self._originalFrame = State(initialValue: originalFrame)
    self.cornerRadius = cornerRadius
  }
  
  var isDissmising: Bool {
    originalFrame != nil || dismissVelocity != nil
  }
  
  public var body: some View {
    ZStack {
      ZoomScrollView(
        size: windowFrame.size,
        onDismiss: { velocity in
          guard !isDissmising else { return }
          Task {
            if originalFrameSaved == nil {
              dismissVelocity = velocity
              Task {
                try? await Task.sleep(seconds: 0.5)
                windowModel.dismiss(id: viewID)
              }
            }
          }
        },
        onDismissProgress: { model.dismissProgress = $0 },
        onMaxDismissReached: { offset in
          guard !isDissmising else { return }
          if model.dismissProgress ?? 0 > 0 {
            model.dismissProgress = 1
          }
          if let originalFrameSaved {
            Task {
              originalFrame = originalFrameSaved + offset
              Task {
                try? await Task.sleep(seconds: 0.5)
                windowModel.dismiss(id: viewID)
              }
            }
          }
        }) {
          HelloImageView(options: imageOptions)
            .clipShape(RoundedRectangle(cornerRadius: originalFrame == nil ? 0 : cornerRadius, style: .continuous))
            .frame(width: originalFrame?.width, height: originalFrame?.height)
            .offset(x: originalFrame?.minX ?? 0, y: originalFrame?.minY ?? 0)
            .frame(width: windowFrame.size.width, height: windowFrame.size.height,
                   alignment: originalFrame == nil ? .center : .topLeading)
            .offset(x: -1000 * (dismissVelocity?.x ?? 0),
                    y: -1000 * (dismissVelocity?.y ?? 0))
            .animation(.linear(duration: 1), value: dismissVelocity)
            .animation(.dampSpring, value: originalFrame)
        }
      ImageViewerCloseButton(onDismiss: {
        if let originalFrameSaved {
          originalFrame = originalFrameSaved
        } else {
          dismissVelocity = CGPoint(x: 0, y: -4)
        }
        Task {
          try? await Task.sleep(seconds: 0.5)
          windowModel.dismiss(id: viewID)
        }
      }).padding(8)
        .padding(.top, safeAreaInsets.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .opacity(!isDissmising ? 1 : 0)
        .animation(.easeInOut(duration: 0.36), value: isDissmising)
        .environment(model)
    }.background(Color.black
      .opacity(!isDissmising ? 1 : 0)
      .animation(.easeInOut(duration: 0.36), value: isDissmising))
    .allowsHitTesting(!isDissmising)
    .onAppear {
      Task {
        try await Task.sleepForOneFrame()
        originalFrame = nil
      }
    }
  }
}
#endif

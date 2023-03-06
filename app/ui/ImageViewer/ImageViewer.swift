#if os(iOS)
import SwiftUI

import HelloCore

public struct ImageViewer: View {
  
  @EnvironmentObject private var uiProperties: UIProperties
  @EnvironmentObject private var windowModel: HelloWindowModel
  
  @State private var dismissVelocity: CGPoint?
  
  private var image: NativeImage
  private var originalFrameSaved: CGRect?
  @State private var originalFrame: CGRect?
  
  public init(image: NativeImage, originalFrame: CGRect?) {
    self.image = image
    self.originalFrameSaved = originalFrame
    self._originalFrame = State(initialValue: originalFrame)
  }
  
  var isDissmising: Bool {
    originalFrame != nil || dismissVelocity != nil
  }
  
  public var body: some View {
    ZStack {
      ZoomScrollView(size: uiProperties.size,
                     onDismiss: { velocity in
        guard !isDissmising else { return }
        Task {
          if originalFrameSaved == nil {
            dismissVelocity = velocity
            windowModel.dismissPopup()
          }
        }
      }, onMaxDismissReached: { offset in
        guard !isDissmising else { return }
        if let originalFrameSaved {
          Task {
            originalFrame = originalFrameSaved + offset
            windowModel.dismissPopup()
          }
        }
      }) {
        Image(image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: originalFrame?.width, height: originalFrame?.height)
          .offset(x: originalFrame?.minX ?? 0, y: originalFrame?.minY ?? 0)
          .frame(width: uiProperties.size.width, height: uiProperties.size.height,
                 alignment: originalFrame == nil ? .center : .topLeading)
          .offset(x: -1000 * (dismissVelocity?.x ?? 0),
                  y: -1000 * (dismissVelocity?.y ?? 0))
          .animation(.linear(duration: 1), value: dismissVelocity)
          .animation(.dampSpring, value: originalFrame)
      }
      BasicButton(action: {
        if let originalFrameSaved {
          originalFrame = originalFrameSaved
        } else {
          dismissVelocity = CGPoint(x: 0, y: -4)
        }
        windowModel.dismissPopup()
      }) {
        Image(systemName: "xmark")
          .font(.system(size: 20, weight: .bold, design: .rounded))
          .foregroundColor(.white)
          .shadow(color: .black.opacity(0.2), radius: 8)
          .frame(width: 44, height: 44)
          .clickable()
      }.padding(8)
        .padding(.top, uiProperties.safeAreaInsets.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .opacity(!isDissmising ? 1 : 0)
        .animation(.easeInOut(duration: 0.36), value: isDissmising)
        
    }.background(Color.black
      .opacity(!isDissmising ? 1 : 0)
      .animation(.easeInOut(duration: 0.36), value: isDissmising))
    .allowsHitTesting(!isDissmising)
    .onAppear {
      Task {
        try await Task.sleep(seconds: 0.02)
        originalFrame = nil
      }
    }
  }
}
#endif

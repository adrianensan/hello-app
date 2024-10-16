#if os(iOS) || os(tvOS) || os(visionOS)
import SwiftUI

import HelloCore

public struct HelloAppRootView<Content: View>: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(UIProperties.self) private var uiProperties
  
  @Persistent(.showTouches) private var showTouches
  
  private var content: @MainActor () -> Content
  
  public init(_ content: @escaping @MainActor () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    ZStack {
      content()
        .compositingGroup()
//        .grayscale(windowModel.popupViews.isEmpty ? 0 : 0.8)
        .blur(radius: !windowModel.popupViews.isEmpty ? windowModel.blurAmountForPopup : 0)
        .animation(.easeInOut(duration: 0.24), value: !windowModel.popupViews.isEmpty)
        .disabled(!windowModel.popupViews.isEmpty)
        .allowsHitTesting(windowModel.popupViews.isEmpty)
      
      if let topView = windowModel.popupViews.last {
        HelloForEach(windowModel.popupViews) { i, popupView in
          popupView.view()
            .id(popupView.uniqueInstanceID)
            .environment(\.popupID, popupView.id)
            .environment(\.viewID, popupView.uniqueInstanceID)
            .zIndex(3 + 0.1 * Double(i))
            .compositingGroup()
            .blur(radius: topView.id != popupView.id ? windowModel.blurAmountForPopup : 0)
            .disabled(topView.hasExclusiveInteraction && topView.id != popupView.id)
            .allowsHitTesting(!topView.hasExclusiveInteraction || topView.id == popupView.id)
        }
      }
      
      #if os(iOS)
      if showTouches {
        TouchesVisualizer()
          .zIndex(10)
      }
      #endif
    }.dimHomeBarForTheme()
      .observeIsActive()
      .observeActiveTheme()
      .applyVisualEfects()
      .environment(\.safeArea, uiProperties.safeAreaInsets)
      .observeWindowFrame()
      .observeKeyboardFrame()
      .onAppear {
        let persistenceMode = Persistence.mainActorValue(.persistenceMode)
        if persistenceMode != .normal {
          windowModel.show(alert: HelloAlertConfig(
            title: "\(persistenceMode.name) Mode Enabled",
            message: "Nothing you do will persist after you close \(AppInfo.displayName).",
            firstButton: .init(
              name: "Disable",
              action: {
                await Persistence.save(.normal, for: .persistenceMode)
                exitGracefully()
              }, isDestructive: false),
            secondButton: .ok))
        }
      }
      .disabled(windowModel.freeze)
      .allowsHitTesting(!windowModel.freeze)
  }
}
#endif

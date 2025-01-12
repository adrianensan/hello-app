#if os(iOS) || os(tvOS) || os(visionOS)
import SwiftUI

import HelloCore

struct HelloPopupViewModifier: ViewModifier {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(\.viewFrame) private var viewFrame
  
  var popup: HelloWindowModel.PopupWindow?
  
  var frontmostPopup: HelloWindowModel.PopupWindow? { windowModel.popupViews.last }
  
  var backgroundScale: CGFloat { max(0.9, (viewFrame.height - 8) / viewFrame.height) }
  
  func body(content: Content) -> some View {
    content
      .compositingGroup()
//      .offset(y: windowModel.areAnyPopupsPresented(above: popup?.uniqueInstanceID) ? 8 : 0)
      .scaleEffect(windowModel.areAnyPopupsPresented(above: popup?.uniqueInstanceID) ? backgroundScale : 1, anchor: .bottom)
//      .blur(radius: windowModel.areAnyPopupsPresented(above: popup?.uniqueInstanceID) ? windowModel.blurAmountForPopup : 0)
      .disabled(frontmostPopup?.hasExclusiveInteraction == true && windowModel.areAnyPopupsPresented(above: popup?.uniqueInstanceID))
      .allowsHitTesting(frontmostPopup?.hasExclusiveInteraction == false || !windowModel.areAnyPopupsPresented(above: popup?.uniqueInstanceID))
      .animation(.dampSpring, value: windowModel.areAnyPopupsPresented(above: popup?.uniqueInstanceID))
  }
}

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
//        .blur(radius: windowModel.areAnyPopupsPresented(above: nil) ? windowModel.blurAmountForPopup : 0)
//        .animation(.easeInOut(duration: 0.2), value: windowModel.areAnyPopupsPresented(above: nil))
        .modifier(HelloPopupViewModifier(popup: nil))
      
      HelloForEach(windowModel.popupViews) { i, popupView in
        popupView.view()
          .id(popupView.uniqueInstanceID)
//            .offset(y: windowModel.areAnyPopupsPresented(above: popupView.uniqueInstanceID) ? 8 : 0)
          .environment(\.popupID, popupView.id)
          .environment(\.viewID, popupView.uniqueInstanceID)
          .zIndex(3 + 0.1 * Double(i))
          .modifier(HelloPopupViewModifier(popup: popupView))
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

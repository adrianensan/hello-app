import SwiftUI

import HelloCore

@MainActor
@Observable
public class HelloDismissModel {
  public var dismissProgress: CGFloat = 0
  
  public init() {}
}

public class HelloNoModalModel: HelloModalModel {
  
  public init() {
    super.init(forceFullScreen: true, dismiss: {})
  }
  
  public override var animateIn: Bool {
    get { true }
    set {}
  }
  
  public override func dismiss() { }
}

@MainActor
@Observable
public class HelloModalModel {
  
  @ObservationIgnored public var dismissModel: HelloDismissModel
  
  public var animateIn: Bool = false
  public var isDismissed: Bool = false
  
  @ObservationIgnored var onDismiss: () -> Void
  
  private var forceFullScreen: Bool
  
  public init(forceFullScreen: Bool, dismiss: @escaping () -> Void, dismissModel: HelloDismissModel? = nil) {
    self.forceFullScreen = forceFullScreen
    self.onDismiss = dismiss
    self.dismissModel = dismissModel ?? HelloDismissModel()
  }
  
  public func dismiss() {
    isDismissed = true
    onDismiss()
  }
}

@available(tvOS, unavailable)
@MainActor
public struct HelloModalView<Content: View>: View {
  
  @Environment(\.theme) var helloTheme
  @Environment(\.windowFrame) var windowFrame
  @Environment(\.safeArea) var safeAreaInsets
  
  @State var model: HelloModalModel
  
  var forceFullScreen: Bool
  var content: () -> Content
  
  public init(forceFullScreen: Bool = false,
              onDismiss: @escaping () -> Void,
              dismissModel: HelloDismissModel? = nil,
              @ViewBuilder content: @escaping () -> Content) {
    self.forceFullScreen = forceFullScreen
    self.content = content
    self._model = State(wrappedValue: HelloModalModel(forceFullScreen: forceFullScreen,
                                                      dismiss: { onDismiss() },
                                                      dismissModel: dismissModel))
  }
  
  public var isFullScreen: Bool { forceFullScreen || windowFrame.size.width < 720 }
  
  public var settingsSize: CGSize {
    if isFullScreen {
      return windowFrame.size
    } else {
      return CGSize(width: 572, height: 0.82 * (windowFrame.size.height))
    }
  }
  
  public var body: some View {
    ZStack {
      helloTheme.backgroundView(for: RoundedRectangle(cornerRadius: isFullScreen ? Device.current.screenCornerRadius : 24,
                                                        style: .continuous))
      .frame(width: settingsSize.width, height: settingsSize.height)
      //          .offset(multiplier: 100)
      
      content()
        .frame(width: settingsSize.width, height: settingsSize.height, alignment: .topTrailing)
      
      #if os(iOS)
      BasicHelloButton(action: { model.dismiss() }) {
        HelloCloseButton()
      }.zIndex(4)
        .padding(.top, isFullScreen ? safeAreaInsets.top + 8 : 8)
        .padding(.trailing, isFullScreen ? safeAreaInsets.trailing + 8 : 8)
        .frame(width: settingsSize.width, height: settingsSize.height, alignment: .topTrailing)
      #endif
    }.compositingGroup()
      .offset(y: model.animateIn && !model.isDismissed ? 0 : windowFrame.size.height)
      .animation(.spring(), value: model.animateIn && !model.isDismissed)
      .frame(width: settingsSize.width, height: settingsSize.height, alignment: .top)
      .compositingGroup()
      .clipShape(RoundedRectangle(cornerRadius: isFullScreen ? Device.current.screenCornerRadius : 24,
                                  style: .continuous))
      .frame(maxWidth: windowFrame.size.width, maxHeight: windowFrame.size.height)
      .background(Color.black.opacity(model.animateIn ? 0.25 : 0)
        .onTapGesture { model.dismiss() }
        .animation(.easeInOut(duration: 0.2), value: model.animateIn))
      .allowsHitTesting(!model.isDismissed)
      .onAppear { model.animateIn = true }
      .environment(model)
      .environment(model.dismissModel)
  }
}

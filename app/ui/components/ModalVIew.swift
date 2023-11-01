import SwiftUI

import HelloCore

public class HelloDismissModel: ObservableObject {
  @Published public var dismissProgress: CGFloat = 0
  
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
public class HelloModalModel: ObservableObject {
  
  public var dismissModel = HelloDismissModel()
  
  @Published public var animateIn: Bool = false
  @Published public var isDismissed: Bool = false
  
  var onDismiss: () -> Void
  
  private var forceFullScreen: Bool
  
  public init(forceFullScreen: Bool, dismiss: @escaping () -> Void) {
    self.forceFullScreen = forceFullScreen
    self.onDismiss = dismiss
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
  
  @EnvironmentObject var uiConstants: UIProperties
  
  @StateObject var model: HelloModalModel
  
  var forceFullScreen: Bool
  var content: Content
  
  public init(forceFullScreen: Bool = false,
              onDismiss: @escaping () -> Void,
              @ViewBuilder content: @escaping () -> Content) {
    self.forceFullScreen = forceFullScreen
    self.content = content()
    self._model = StateObject(wrappedValue: HelloModalModel(forceFullScreen: forceFullScreen, dismiss: { onDismiss() }))
  }
  
  public var isFullScreen: Bool { forceFullScreen || uiConstants.size.width < 720 }
  
  public var settingsSize: CGSize {
    if isFullScreen {
      return uiConstants.size
    } else {
      return CGSize(width: 572, height: 0.82 * (uiConstants.size.height))
    }
  }
  
  public var body: some View {
    ZStack {
      ZStack {
        helloTheme.backgroundView(for: RoundedRectangle(cornerRadius: isFullScreen ? Device.current.screenCornerRadius : 24,
                                                          style: .continuous))
        .frame(width: settingsSize.width, height: settingsSize.height)
        //          .offset(multiplier: 100)
        
        content
          .frame(width: settingsSize.width, height: settingsSize.height, alignment: .topTrailing)
        
        BasicHelloButton(action: { model.dismiss() }) {
          HelloCloseButton()
        }.zIndex(4)
          .padding(.top, isFullScreen ? uiConstants.safeAreaInsets.top + 8 : 8)
          .padding(.trailing, isFullScreen ? uiConstants.safeAreaInsets.trailing + 8 : 8)
          .frame(width: settingsSize.width, height: settingsSize.height, alignment: .topTrailing)
      }.compositingGroup()
        .offset(y: model.animateIn && !model.isDismissed ? 0 : uiConstants.size.height)
        .animation(.spring(), value: model.animateIn && !model.isDismissed)
      
    }.frame(width: settingsSize.width, height: settingsSize.height, alignment: .top)
      .compositingGroup()
      .clipShape(RoundedRectangle(cornerRadius: isFullScreen ? Device.current.screenCornerRadius : 24,
                                  style: .continuous))
      .frame(maxWidth: uiConstants.size.width, maxHeight: uiConstants.size.height)
      .background(Color.black.opacity(model.animateIn ? 0.25 : 0)
        .onTapGesture { model.dismiss() }
        .animation(.easeInOut(duration: 0.2), value: model.animateIn))
      .allowsHitTesting(!model.isDismissed)
      .onAppear { model.animateIn = true }
      .environmentObject(model)
      .environmentObject(model.dismissModel)
  }
}

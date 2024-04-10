import SwiftUI

public extension View {
  func nest(transform: (Self) -> some View) -> some View {
    transform(self)
  }
}

public extension Animation {
  static var pageAnimation: Animation {
    .spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.35)
  }
}

@MainActor
public struct NavigationPagerView: View {
  
  @Environment(\.theme) var theme
  @Environment(\.safeArea) var safeAreaInsets
  
  var model: PagerModel
  
  @State var viewDepth: CGFloat = 0  
  
  public init(model: PagerModel) {
    self.model = model
  }
  
  var previousPageOptions: PagerPageOptions {
    model.viewStack[max(0, model.viewDepth - 2)].options
  }
  
  var currentPageOptions: PagerPageOptions {
    model.activePage?.options ?? PagerPageOptions()
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        HStack(spacing: 0) {
          ForEach(model.viewStack) { page in
            page.view
              .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
              .allowsHitTesting(model.allowInteraction && model.activePageID == page.id)
              .transition(.asymmetric(insertion: .opacity.animation(.linear(duration: 0)),
                                      removal: .opacity.animation(.linear(duration: 0.1).delay(0.4))))
          }
        }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
          .handlePageBackSwipe(pageSize: geometry.size)
        
        #if os(iOS)
        if model.config.allowsBack {
          HelloButton(haptics: .action, action: { model.popView() }) {
            BackButton(backText: "Back")
              .foregroundColor(
//                backDragGestureState.width > 32
//                ? previousPageOptions.headerContentColorOverride?.swiftuiColor ?? theme.text.primary.color
//                : 
                    currentPageOptions.headerContentColorOverride?.swiftuiColor ?? theme.text.primary.color
              )
          }.zIndex(4)
            .padding(.horizontal, 8)
            .frame(height: model.config.defaultNavBarHeight)
            .padding(.top, safeAreaInsets.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .opacity(model.viewDepth > 1 && currentPageOptions.allowBackOverride != false ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: model.viewDepth)
            .allowsHitTesting(model.viewDepth > 1 && currentPageOptions.allowBackOverride != false)
        }
        #endif
      }.frame(width: geometry.size.width, height: geometry.size.height)
//        .clipShape(Rectangle())
    }.environment(model)
      .environment(model.backProgressModel)
      .environment(\.helloPagerConfig, model.config)
      .environment(\.helloDismiss, { model.popView() })
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

private struct HelloPagerConfigEnvironmentKey: EnvironmentKey {
  static let defaultValue = HelloPagerConfig()
}

public extension EnvironmentValues {
  var helloPagerConfig: HelloPagerConfig {
    get { self[HelloPagerConfigEnvironmentKey.self] }
    set { self[HelloPagerConfigEnvironmentKey.self] = newValue }
  }
}

private struct HelloDismissEnvironmentKey: EnvironmentKey {
  static let defaultValue = { }
}

public extension EnvironmentValues {
  var helloDismiss: () -> Void {
    get { self[HelloDismissEnvironmentKey.self] }
    set { self[HelloDismissEnvironmentKey.self] = newValue }
  }
}

import SwiftUI

public extension Animation {
  static var pageAnimation: Animation {
    .spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.35)
  }
}

@MainActor
public struct NavigationPagerView: View {
  
  @Environment(\.theme) var theme
  @Environment(\.safeArea) var safeAreaInsets
  
  @ObservedObject var model: PagerModel
  var allowsBack: Bool
  
  @State var viewDepth: CGFloat = 0
  
  @GestureState var backDragGestureState: CGSize = .zero
  
  public init(model: PagerModel, allowsBack: Bool = true) {
    self.model = model
    self.allowsBack = allowsBack
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
          .compositingGroup()
          .offset(x: -CGFloat(model.viewDepth - 1) * geometry.size.width + backDragGestureState.width)
          .animation(.pageAnimation, value: model.viewDepth)
          .animation(backDragGestureState == .zero ? .pageAnimation : .interactive, value: backDragGestureState)
        
        #if os(iOS)
        if allowsBack {
          BasicButton(haptics: .action, action: { model.popView() }) {
            BackButton()
              .foregroundColor(
                backDragGestureState.width > 32
                ? previousPageOptions.headerContentColorOverride?.swiftuiColor ?? theme.text.primary.color
                : currentPageOptions.headerContentColorOverride?.swiftuiColor ?? theme.text.primary.color
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
    }.environmentObject(model)
      .environmentObject(model.backProgressModel)
      .environment(\.helloPagerConfig, model.config)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(ClearClickableView())
      .gesture(DragGesture(minimumDistance: allowsBack && model.viewDepth > 1 && currentPageOptions.allowBackOverride != false ? 8 : .infinity, coordinateSpace: .global)
        .updating($backDragGestureState) { drag, state, transaction in
          if drag.translation.width < 0 {
            state = CGSize(width: 0, height: 0)
          } else {
            state = CGSize(width: drag.translation.width, height: 0)
          }
        }.onEnded { drag in
          if drag.predictedEndTranslation.width > 200 {
            model.popView()
            ButtonHaptics.buttonFeedback()
          }
        })
      .onChange(of: backDragGestureState) {
        let progress = min(1, max(0, $0.width / 200))
        if model.backProgressModel.backProgress != progress {
          model.backProgressModel.backProgress = progress
        }
      }
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

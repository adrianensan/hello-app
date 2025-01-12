import SwiftUI

public enum GestureType: Hashable, Sendable {
  case normal
  case highPriority
  case disabled
}

public extension View {
  func nest(@ViewBuilder transform: @MainActor (Self) -> some View) -> some View {
    transform(self)
  }
  
  @ViewBuilder
  func gesture(type: GestureType, _ gesture: some Gesture) -> some View {
    switch type {
    case .normal:
      self.gesture(gesture)
    case .highPriority:
      self.simultaneousGesture(gesture)
    case .disabled:
      self
    }
  }
}

public extension Animation {
  static var pageAnimation: Animation {
//    .dampSpring
    .interpolatingSpring(duration: 0.26, bounce: 0, initialVelocity: 0)
//    .spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)
  }
}

public struct HelloPager: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeAreaInsets
  @Environment(\.pageShape) private var pageShape
  #if os(iOS)
  @OptionalEnvironment(HelloSheetModel.self) private var sheetModel
  #endif
  
  @State private var model: HelloPagerModel
  
  public init(model: HelloPagerModel) {
    _model = State(initialValue: model)
  }
  
  public init(name: String? = nil, rootView: @escaping @MainActor () -> some View) {
    _model = State(initialValue: HelloPagerModel(rootPage: PagerPage(name: name, view: rootView)))
  }
  
  private var config: HelloPagerConfig {
    model.config
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        HelloForEach(model.viewStack) { index, page in
          page.view()
            .environment(\.pageID, page.id)
            .environment(\.viewID, page.instanceID)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .zIndex(4 + 0.1 * Double(index))
//              .clipShape(RoundedRectangle(cornerRadius: Device.current.screenCornerRadius, style: .continuous))
            .handlePageBackSwipe(pageID: page.id, pageSize: geometry.size)
            .id(page.instanceID)
        }
//          .background(ClearClickableView().onTapGesture {
//            globalDismissKeyboard()
//          })
        
//        #if os(iOS)
//        if model.config.allowsBack {
//          HelloButton(haptics: .none, action: { model.popView() }) {
//            BackButton()
//              .foregroundStyle(
////                backDragGestureState.width > 32
////                ? previousPageOptions.headerContentColorOverride?.swiftuiColor ?? theme.text.primary.color
////                : 
//                    currentPageOptions.headerContentColorOverride?.swiftuiColor ?? theme.text.primary.color
//              )
//          }.zIndex(4)
//            .padding(.horizontal, 8)
//            .frame(height: model.config.navBarHeight)
//            .padding(.top, {
//              #if os(iOS) || os(visionOS)
//              safeAreaInsets.top
//              #elseif os(macOS)
//              if safeAreaInsets.top > 0 {
//                0.5 * safeAreaInsets.top + 8
//              } else {
//                safeAreaInsets.top
//              }
//              #endif
//            }())
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//            .opacity(model.viewDepth > 1 && currentPageOptions.allowBackOverride != false ? 1 : 0)
//            .animation(.easeInOut(duration: 0.2), value: model.viewDepth)
//            .allowsHitTesting(model.viewDepth > 1 && currentPageOptions.allowBackOverride != false)
//        }
//        #endif
      }.frame(width: geometry.size.width, height: geometry.size.height)
        .compositingGroup()
//        .background(theme.backgroundView)
//        .background(theme.foreground.primary.color
//          .opacity(0.05 + 0.05 * theme.theme.baseLayer.foregroundPrimary.mainColor.brightness))
//        .clipShape(Rectangle())
    }.environment(model)
      .environment(model.backProgressModel)
      .environment(\.helloPagerConfig, config)
      .environment(\.helloDismiss, { model.popView() })
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .onAppear {
        #if os(iOS)
        if let sheetModel {
          sheetModel.pagerModel = model
        }
        #endif
      }
  }
}

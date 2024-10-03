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
    .spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)
  }
}

public struct NavigationPagerView: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeAreaInsets
  @Environment(\.pageShape) private var pageShape
  #if os(iOS)
  @OptionalEnvironment(HelloSheetModel.self) private var sheetModel
  #endif
  
  @State private var model: PagerModel
  
  public init(model: PagerModel) {
    _model = State(initialValue: model)
  }
  
  public init(name: String? = nil, rootView: @escaping @MainActor () -> some View) {
    _model = State(initialValue: PagerModel(rootPage: PagerPage(name: name, view: rootView)))
  }
  
//  private var previousPageOptions: PagerPageOptions {
//    model.viewStack[max(0, model.viewDepth - 2)].options
//  }
  
  private var currentPageOptions: PagerPageOptions {
    model.activePage?.options ?? PagerPageOptions()
  }
  
  private var config: HelloPagerConfig {
    model.config
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        ForEach(model.viewStack) { page in
          let index = model.pageIndex(for: page.id) ?? 0
          page.view()
            .environment(\.pageID, page.id)
            .environment(\.viewID, page.instanceID)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .clipShape(pageShape)
            .background(theme.backgroundView(for: pageShape, isBaseLayer: true)
              .shadow(color: .black.opacity(model.activePageID == page.id ? 0.2 : 0), radius: 16)
              .onTapGesture { globalDismissKeyboard() })
            .zIndex(4 + 0.1 * Double(index))
//              .clipShape(RoundedRectangle(cornerRadius: Device.current.screenCornerRadius, style: .continuous))
            .handlePageBackSwipe(pageID: page.id, pageSize: geometry.size)
            .disabled(model.activePageID != page.id)
            .allowsHitTesting(model.activePageID == page.id)
            .id(page.instanceID)
        }
//          .background(ClearClickableView().onTapGesture {
//            globalDismissKeyboard()
//          })
        
//        #if os(iOS)
//        if model.config.allowsBack {
//          HelloButton(haptics: .none, action: { model.popView() }) {
//            BackButton()
//              .foregroundColor(
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

#if os(iOS)
import SwiftUI

import HelloCore

public struct TopBlurScrollView<Content: View>: View {
  
  @Environment(\.theme) private var theme
  
  @EnvironmentObject private var uiProperties: UIProperties
  
  @State private var isScrolled: Bool = false
  
  @Binding private var scrollToTop: Bool
  
  private let allowScroll: Bool
  private let showsIndicators: Bool
  private let safeAreaCoverColor: HelloColor?
  private let bottomSafeArea: CGFloat?
  private var onScrollUpdate: ((CGFloat) -> Void)?
  private var onDismissUpdate: ((CGFloat) -> Void)?
  private var content: Content
  
  public init(allowScroll: Bool = true,
              showsIndicators: Bool = true,
              safeAreaCoverColor: HelloColor? = nil,
              bottomSafeArea: CGFloat? = nil,
              scrollToTopTrigger: Binding<Bool> = .constant(false),
              onScrollUpdate: ((CGFloat) -> Void)? = nil,
              onDismissUpdate: ((CGFloat) -> Void)? = nil,
              @ViewBuilder content: () -> Content) {
    self.allowScroll = allowScroll
    self.showsIndicators = showsIndicators
    self.safeAreaCoverColor = safeAreaCoverColor
    self.bottomSafeArea = bottomSafeArea
    self._scrollToTop = scrollToTopTrigger
    self.onScrollUpdate = onScrollUpdate
    self.onDismissUpdate = onDismissUpdate
    self.content = content()
  }
  
  private var hideBlur: Bool { safeAreaCoverColor?.alpha == 0 }
  
  public var body: some View {
    ZStack(alignment: .top) {
      CustomScrollView(allowScroll: allowScroll,
                       showsIndicators: false,
                       scrollToTopTrigger: $scrollToTop,
                       onScrollUpdate: { scrollOffset in
        let isScrolled = scrollOffset < -32
        if self.isScrolled != isScrolled {
          self.isScrolled = isScrolled
        }
        onScrollUpdate?(scrollOffset)
      }, onDismissUpdate: onDismissUpdate) {
        content
      }.safeAreaInset(edge: .top) {
        Color.clear.frame(height: uiProperties.safeAreaInsets.top)
      }.safeAreaInset(edge: .bottom) {
        Color.clear.frame(height: bottomSafeArea ?? uiProperties.safeAreaInsets.bottom + 68)
      }.compositingGroup()
      
      if !hideBlur {
        ZStack {
          Rectangle().fill(.ultraThinMaterial)
          safeAreaCoverColor?.swiftuiColor ?? theme.backgroundColor.opacity(0.8)
        }.frame(maxWidth: .infinity)
          .frame(height: uiProperties.safeAreaInsets.top)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
          .opacity(isScrolled ? 1 : 0)
          .animation(nil, value: isScrolled)
      }
    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}
#endif

#if os(iOS)
import SwiftUI
import Observation

import HelloCore

@available(iOS 17, *)
@MainActor
@Observable
public class HelloScrollViewModel: ObservableObject {
  
}

@MainActor
public struct HelloScrollView<Content: View>: View {
  
  private class NonObservedStorage {
    var coordinateSpaceName: String = UUID().uuidString
    var readyForDismiss: Bool = true
    var scrollOffset: CGFloat = 0
    var dismissProgress: CGFloat = 0
    var isDismissing: Bool = true
    var timeReachedtop: TimeInterval = 0
  }
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeAreaInsets
  @Environment(\.keyboardFrame) private var keyboardFrame
  
  @State private var nonObservedStorage = NonObservedStorage()
  @Binding private var scrollToTop: Bool
  
  private let allowScroll: Bool
  private let showsIndicators: Bool
  private var onScrollUpdate: ((CGFloat) -> Void)?
  private var onDismissUpdate: ((CGFloat) -> Void)?
  private var content: Content
  
  public init(allowScroll: Bool = true,
              showsIndicators: Bool = true,
              scrollToTopTrigger: Binding<Bool> = .constant(false),
              onScrollUpdate: ((CGFloat) -> Void)? = nil,
              onDismissUpdate: ((CGFloat) -> Void)? = nil,
              @ViewBuilder content: () -> Content) {
    self.allowScroll = allowScroll
    self.showsIndicators = showsIndicators
    self._scrollToTop = scrollToTopTrigger
    self.onScrollUpdate = onScrollUpdate
    self.onDismissUpdate = onDismissUpdate
    self.content = content()
  }
  
  func update(offset: CGFloat) {
    Task {
      if offset < 0 {
        nonObservedStorage.timeReachedtop = Date().timeIntervalSince1970
      }
      
      if nonObservedStorage.readyForDismiss
          && !nonObservedStorage.isDismissing
          && offset > nonObservedStorage.scrollOffset {
        nonObservedStorage.isDismissing = true
      }
      
      if !nonObservedStorage.readyForDismiss
          && offset >= 0 && offset < nonObservedStorage.scrollOffset
          && Date().timeIntervalSince1970 - nonObservedStorage.timeReachedtop > 0.1 {
        nonObservedStorage.readyForDismiss = true
      } else if nonObservedStorage.readyForDismiss && offset < 0 {
        nonObservedStorage.readyForDismiss = false
        nonObservedStorage.isDismissing = false
      }
      
      if nonObservedStorage.scrollOffset != offset {
        onScrollUpdate?(offset)
        nonObservedStorage.scrollOffset = offset
      }
      
      if let onDismissUpdate = onDismissUpdate {
        if nonObservedStorage.isDismissing {
          let newDismissProgress = min(1, max(0, offset / 100))
          guard nonObservedStorage.dismissProgress != newDismissProgress else { return }
          nonObservedStorage.dismissProgress = newDismissProgress
          onDismissUpdate(newDismissProgress)
        } else if nonObservedStorage.dismissProgress != 0 {
          nonObservedStorage.dismissProgress = 0
          onDismissUpdate(0)
        }
      }
    }
  }
  
  public var body: some View {
    ScrollViewReader { scrollView in
      ScrollView(allowScroll ? .vertical : [], showsIndicators: showsIndicators) {
        VStack(spacing: 0) {
          PositionReaderView(onPositionChange: { update(offset: $0.y) },
                             coordinateSpace: .named(nonObservedStorage.coordinateSpaceName))
          .frame(height: 0)
          content
        }.id("scrollViewTop")
      }.coordinateSpace(name: nonObservedStorage.coordinateSpaceName)
        .safeAreaInset(edge: .top, spacing: 0) {
          Color.clear.frame(height: safeAreaInsets.top)
        }.safeAreaInset(edge: .bottom, spacing: 0) {
          Color.clear.frame(height: max(safeAreaInsets.bottom, keyboardFrame.size.height))
        }.onChange(of: scrollToTop) {
          if $0 {
//            withAnimation(.easeOut(duration: 0.5)) {
            scrollView.scrollTo("scrollViewTop", anchor: .top)
//            }
            scrollToTop = false
          }
        }.compositingGroup()
    }
  }
}

@MainActor
public struct TopBlurScrollView<Content: View>: View {
  
  private class NonObservedStorage {
    var coordinateSpaceName: String = UUID().uuidString
    var readyForDismiss: Bool = true
    var scrollOffset: CGFloat = 0
    var dismissProgress: CGFloat = 0
    var isDismissing: Bool = true
    var timeReachedtop: TimeInterval = 0
  }
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeAreaInsets
  @Environment(\.keyboardFrame) private var keyboardFrame
  
  @State private var nonObservedStorage = NonObservedStorage()
  @State private var isScrolled: Bool = false
  @Binding private var scrollToTop: Bool
  
  private let showsIndicators: Bool
  private let safeAreaCoverColor: HelloColor?
  private let bottomSafeArea: CGFloat?
  private var onScrollUpdate: ((CGFloat) -> Void)?
  private var onDismissUpdate: ((CGFloat) -> Void)?
  private var content: Content
  
  public init(showsIndicators: Bool = true,
              safeAreaCoverColor: HelloColor? = nil,
              bottomSafeArea: CGFloat? = nil,
              scrollToTopTrigger: Binding<Bool> = .constant(false),
              onScrollUpdate: ((CGFloat) -> Void)? = nil,
              onDismissUpdate: ((CGFloat) -> Void)? = nil,
              @ViewBuilder content: () -> Content) {
    self.showsIndicators = showsIndicators
    self.safeAreaCoverColor = safeAreaCoverColor
    self.bottomSafeArea = bottomSafeArea
    self._scrollToTop = scrollToTopTrigger
    self.onScrollUpdate = onScrollUpdate
    self.onDismissUpdate = onDismissUpdate
    self.content = content()
  }
  
  private var hideBlur: Bool { safeAreaCoverColor?.alpha == 0 }
  
  func update(offset: CGFloat) {
    Task {
      if offset < 0 {
        nonObservedStorage.timeReachedtop = Date().timeIntervalSince1970
      }
      
      if nonObservedStorage.readyForDismiss
          && !nonObservedStorage.isDismissing
          && offset > nonObservedStorage.scrollOffset {
        nonObservedStorage.isDismissing = true
      }
      
      if !nonObservedStorage.readyForDismiss
          && offset >= 0 && offset < nonObservedStorage.scrollOffset
          && Date().timeIntervalSince1970 - nonObservedStorage.timeReachedtop > 0.1 {
        nonObservedStorage.readyForDismiss = true
      } else if nonObservedStorage.readyForDismiss && offset < 0 {
        nonObservedStorage.readyForDismiss = false
        nonObservedStorage.isDismissing = false
      }
      
      if nonObservedStorage.scrollOffset != offset {
        let isScrolled = offset < -32
        if self.isScrolled != isScrolled {
          self.isScrolled = isScrolled
        }
        onScrollUpdate?(offset)
        nonObservedStorage.scrollOffset = offset
      }
      
      if let onDismissUpdate = onDismissUpdate {
        if nonObservedStorage.isDismissing {
          let newDismissProgress = min(1, max(0, offset / 100))
          guard nonObservedStorage.dismissProgress != newDismissProgress else { return }
          nonObservedStorage.dismissProgress = newDismissProgress
          onDismissUpdate(newDismissProgress)
        } else if nonObservedStorage.dismissProgress != 0 {
          nonObservedStorage.dismissProgress = 0
          onDismissUpdate(0)
        }
      }
    }
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      ScrollViewReader { scrollView in
        ScrollView(.vertical, showsIndicators: showsIndicators) {
          VStack(spacing: 0) {
            PositionReaderView(onPositionChange: { update(offset: $0.y) },
                               coordinateSpace: .named(nonObservedStorage.coordinateSpaceName))
            .frame(height: 0)
            content
          }.id("scrollViewTop")
        }.coordinateSpace(name: nonObservedStorage.coordinateSpaceName)
          .safeAreaInset(edge: .top, spacing: 0) {
            Color.clear.frame(height: safeAreaInsets.top)
          }.safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: bottomSafeArea ?? max(safeAreaInsets.bottom, keyboardFrame.size.height))
          }.onChange(of: scrollToTop) {
            if $0 {
              withAnimation(.easeOut(duration: 0.5)) {
                scrollView.scrollTo("scrollViewTop", anchor: .top)
              }
              scrollToTop = false
            }
          }.compositingGroup()
      }
      
      if !hideBlur {
        ZStack {
          Rectangle().fill(.ultraThinMaterial)
          safeAreaCoverColor?.swiftuiColor ?? theme.backgroundColor.opacity(0.8)
        }.frame(maxWidth: .infinity)
          .frame(height: safeAreaInsets.top)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
          .opacity(isScrolled ? 1 : 0)
          .animation(nil, value: isScrolled)
      }
    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}
#endif

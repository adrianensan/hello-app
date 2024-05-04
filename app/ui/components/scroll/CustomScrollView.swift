#if os(iOS)
import SwiftUI

import HelloCore

@MainActor
public struct CustomScrollView<Content: View>: View {
  
  private class NonObservedStorage {
    var coordinateSpaceName: String = UUID().uuidString
    var readyForDismiss: Bool = true
    var scrollOffset: CGFloat = 0
    var dismissProgress: CGFloat = 0
    var isDismissing: Bool = true
    var timeReachedtop: TimeInterval = 0
  }
  
  let allowScroll: Bool
  let showsIndicators: Bool
  var onScrollUpdate: (CGFloat) -> Void
  var onDismissUpdate: ((CGFloat) -> Void)?
  var content: Content
  
  @State private var nonObservedStorage = NonObservedStorage()
  @Binding private var scrollToTop: Bool
  
  public init(allowScroll: Bool = true,
              showsIndicators: Bool = true,
              scrollToTopTrigger: Binding<Bool> = .constant(false),
              onScrollUpdate: @escaping (CGFloat) -> Void,
              onDismissUpdate: ((CGFloat) -> Void)? = nil,
              @ViewBuilder content: @escaping () -> Content) {
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
        nonObservedStorage.timeReachedtop = epochTime
      }
      
      if nonObservedStorage.readyForDismiss
          && !nonObservedStorage.isDismissing
          && offset > nonObservedStorage.scrollOffset {
        nonObservedStorage.isDismissing = true
      }
      
      if !nonObservedStorage.readyForDismiss
          && offset >= 0 && offset < nonObservedStorage.scrollOffset
          && epochTime - nonObservedStorage.timeReachedtop > 0.1 {
        nonObservedStorage.readyForDismiss = true
      } else if nonObservedStorage.readyForDismiss && offset < 0 {
        nonObservedStorage.readyForDismiss = false
        nonObservedStorage.isDismissing = false
      }
      
      if nonObservedStorage.scrollOffset != offset {
        onScrollUpdate(offset)
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
        .onChange(of: scrollToTop) {
          if $0 {
            withAnimation(.easeOut(duration: 0.5)) {
              scrollView.scrollTo("scrollViewTop", anchor: .top)
            }
            scrollToTop = false
          }
        }
    }
  }
}

#endif

#if os(iOS)
import SwiftUI
import Observation

import HelloCore

public enum HelloScrollTarget: Sendable, Identifiable, Hashable {
  case top
  case view(id: String)
  
  public var id: String {
    switch self {
    case .top: "scrollViewTop"
    case .view(let id): id
    }
  }
}

@MainActor
@Observable
public class HelloScrollViewModel: ObservableObject {
  
  fileprivate var scrollTarget: HelloScrollTarget?
  
  public func scroll(to scrollTarget: HelloScrollTarget) {
    self.scrollTarget = scrollTarget
  }
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
  
  @State private var model = HelloScrollViewModel()
  @State private var nonObservedStorage = NonObservedStorage()
  
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
      
      guard nonObservedStorage.scrollOffset != offset else { return }
      onScrollUpdate?(offset)
      nonObservedStorage.scrollOffset = offset
      
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
        }.id(HelloScrollTarget.top.id)
      }.coordinateSpace(name: nonObservedStorage.coordinateSpaceName)
        .safeAreaInset(edge: .top, spacing: 0) {
          Color.clear.frame(height: safeAreaInsets.top)
        }.safeAreaInset(edge: .bottom, spacing: 0) {
          Color.clear.frame(height: max(safeAreaInsets.bottom, keyboardFrame.size.height))
        }.onChange(of: model.scrollTarget) {
          if let scrollTarget = model.scrollTarget {
            //            withAnimation(.easeOut(duration: 0.5)) {
            scrollView.scrollTo(scrollTarget.id, anchor: .top)
            //            }
          }
        }.compositingGroup()
    }
  }
}
#endif

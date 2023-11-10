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
public class HelloScrollModel {
  
  fileprivate var scrollTarget: HelloScrollTarget?
  public fileprivate(set) var scrollOffset: CGFloat = 0
  public fileprivate(set) var dismissProgress: CGFloat = 0
  
  @ObservationIgnored fileprivate var coordinateSpaceName: String = UUID().uuidString
  @ObservationIgnored fileprivate var readyForDismiss: Bool = true
  @ObservationIgnored fileprivate var isDismissing: Bool = true
  @ObservationIgnored fileprivate var timeReachedtop: TimeInterval = 0
  @ObservationIgnored public var scrollThreshold: CGFloat
  
  @ObservationIgnored private var isActive: Bool = true
  
  public init(scrollThreshold: CGFloat = 0) {
    self.scrollThreshold = scrollThreshold
  }
  
  public var overscroll: CGFloat { max(0, scrollOffset) }
  
  public var hasScrolled: Bool { scrollOffset < scrollThreshold }
  
  public func scroll(to scrollTarget: HelloScrollTarget) {
    self.scrollTarget = scrollTarget
  }
  
  public func setActive(_ isActive: Bool) {
    self.isActive = isActive
  }
  
  fileprivate func update(offset: CGFloat) {
    guard isActive else { return }
    Task {
      if offset < 0 {
        timeReachedtop = Date().timeIntervalSince1970
      }
      
      if readyForDismiss
          && !isDismissing
          && offset > scrollOffset {
        isDismissing = true
      }
      
      if !readyForDismiss
          && offset >= 0 && offset < scrollOffset
          && Date().timeIntervalSince1970 - timeReachedtop > 0.1 {
        readyForDismiss = true
      } else if readyForDismiss && offset < 0 {
        readyForDismiss = false
        isDismissing = false
      }
      
      guard scrollOffset != offset else { return }
      scrollOffset = offset
      
      if isDismissing {
        let newDismissProgress = min(1, max(0, offset / 100))
        guard dismissProgress != newDismissProgress else { return }
        dismissProgress = newDismissProgress
      } else if dismissProgress != 0 {
        dismissProgress = 0
      }
    }
  }
}

@MainActor
public struct HelloScrollView<Content: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeAreaInsets
  @Environment(\.keyboardFrame) private var keyboardFrame
  
  @State private var model: HelloScrollModel
  
  private let allowScroll: Bool
  private let showsIndicators: Bool
  private var content: Content
  
  public init(allowScroll: Bool = true,
              showsIndicators: Bool = true,
              model: HelloScrollModel? = nil,
              @ViewBuilder content: () -> Content) {
    self.allowScroll = allowScroll
    self.showsIndicators = showsIndicators
    self.content = content()
    _model = State(initialValue: model ?? HelloScrollModel())
  }
  
  public var body: some View {
    ScrollViewReader { scrollView in
      ScrollView(allowScroll ? .vertical : [], showsIndicators: showsIndicators) {
        VStack(spacing: 0) {
          PositionReaderView(onPositionChange: { model.update(offset: $0.y) },
                             coordinateSpace: .named(model.coordinateSpaceName))
          .frame(height: 0)
          content.environment(model)
        }.id(HelloScrollTarget.top.id)
      }.coordinateSpace(name: model.coordinateSpaceName)
        .safeAreaInset(edge: .top, spacing: 0) {
          Color.clear.frame(height: safeAreaInsets.top)
        }.safeAreaInset(edge: .bottom, spacing: 0) {
          Color.clear.frame(height: max(safeAreaInsets.bottom, keyboardFrame.size.height))
        }.onChange(of: model.scrollTarget) {
          if let scrollTarget = model.scrollTarget {
            //            withAnimation(.easeOut(duration: 0.5)) {
            scrollView.scrollTo(scrollTarget.id, anchor: .top)
            model.scrollTarget = nil
            //            }
          }
        }.compositingGroup()
    }
  }
}
#endif

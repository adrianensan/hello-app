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
  @ObservationIgnored fileprivate var animateScroll: Bool = false
  public fileprivate(set) var scrollOffset: CGFloat = 0
  public fileprivate(set) var dismissProgress: CGFloat = 0
  
  public var scrollThreshold: CGFloat
  fileprivate let coordinateSpaceName: String = UUID().uuidString
  @ObservationIgnored fileprivate var readyForDismiss: Bool = true
  @ObservationIgnored fileprivate var isDismissing: Bool = true
  @ObservationIgnored fileprivate var timeReachedTop: TimeInterval = 0
  @ObservationIgnored private var isActive: Bool = true
  
  public init(scrollThreshold: CGFloat = 0) {
    self.scrollThreshold = scrollThreshold
  }
  
  public var overscroll: CGFloat = 0
  
  public var hasScrolled: Bool = false// { scrollOffset < scrollThreshold }
  
  public var scrollThresholdProgress: Double { min(1, max(0, scrollOffset / min(-0.01, scrollThreshold))) }
  
  public func scroll(to scrollTarget: HelloScrollTarget, animated: Bool = true) {
    animateScroll = animated
    self.scrollTarget = scrollTarget
  }
  
  public func setActive(_ isActive: Bool) {
    self.isActive = isActive
  }
  
  fileprivate func update(offset: CGFloat) {
    guard isActive else { return }
    if offset < 0 {
      timeReachedTop = Date().timeIntervalSince1970
    }
    
    if readyForDismiss
        && !isDismissing
        && offset > scrollOffset {
      isDismissing = true
    }
    
    if !readyForDismiss
        && offset >= 0 && offset < scrollOffset
        && Date().timeIntervalSince1970 - timeReachedTop > 0.1 {
      readyForDismiss = true
    } else if readyForDismiss && offset < 0 {
      readyForDismiss = false
      isDismissing = false
    }
    
    guard scrollOffset != offset else { return }
    scrollOffset = offset
    let hasScrolled = scrollOffset < scrollThreshold
    if self.hasScrolled != hasScrolled {
      self.hasScrolled = hasScrolled
    }
    
    if scrollOffset > 0 {
      overscroll = scrollOffset
    } else if overscroll != 0 {
      overscroll = 0
    }
    
    if isDismissing {
      let newDismissProgress = min(1, max(0, offset / 100))
      guard dismissProgress != newDismissProgress else { return }
      dismissProgress = newDismissProgress
    } else if dismissProgress != 0 {
      dismissProgress = 0
    }
  }
}

@MainActor
public struct HelloScrollView<Content: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.keyboardFrame) private var keyboardFrame
  
  @State private var model: HelloScrollModel
  
  private let allowScroll: Bool
  private let showsIndicators: Bool
  private var content: () -> Content
  
  public init(allowScroll: Bool = true,
              showsIndicators: Bool = true,
              model: HelloScrollModel? = nil,
              @ViewBuilder content: @escaping () -> Content) {
    self.allowScroll = allowScroll
    self.showsIndicators = showsIndicators
    self.content = content
    _model = State(wrappedValue: model ?? HelloScrollModel())
  }
  
  public var body: some View {
//    let _ = Self._printChanges()
    ScrollViewReader { scrollView in
      ScrollView(allowScroll ? .vertical : [], showsIndicators: showsIndicators) {
        VStack(spacing: 0) {
          PositionReaderView(onPositionChange: { model.update(offset: $0.y) },
                             coordinateSpace: .named(model.coordinateSpaceName))
            .frame(height: 0)
          content()
        }.id(HelloScrollTarget.top.id)
      }.coordinateSpace(name: model.coordinateSpaceName)
        .insetBySafeArea()
        .onChange(of: model.scrollTarget) {
          guard let scrollTarget = model.scrollTarget else { return }
          model.scrollTarget = nil
          withAnimation(model.animateScroll ? .easeOut(duration: 0.5) : nil) {
            scrollView.scrollTo(scrollTarget.id, anchor: .top)
          }
        }
    }.environment(model)
  }
}
#endif

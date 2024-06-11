import SwiftUI
import Observation

import HelloCore

public enum HelloScrollTarget: Sendable, Identifiable, Hashable {
  case top
  case bottom
  case view(id: String)
  
  public var id: String {
    switch self {
    case .top: "scroll-view-top"
    case .bottom: "scroll-view-bottom"
    case .view(let id): id
    }
  }
}

@MainActor
@Observable
public class HelloScrollModel {
  
  fileprivate var scrollTarget: HelloScrollTarget?
  @ObservationIgnored fileprivate var scrollAnimation: Animation?
  public fileprivate(set) var scrollOffset: CGFloat = 0
  public fileprivate(set) var dismissProgress: CGFloat = 0
  public fileprivate(set) var isDismissed: Bool = false
  public fileprivate(set) var showScrollIndicator: Bool
  
  public var scrollThreshold: CGFloat?
  var defaultScrollThreshold: CGFloat = 0
  
  var effectiveScrollThreshold: CGFloat { scrollThreshold ?? defaultScrollThreshold }
  
  fileprivate let coordinateSpaceName: String = UUID().uuidString
  @ObservationIgnored fileprivate var readyForDismiss: Bool = true
  @ObservationIgnored fileprivate var isDismissing: Bool = true
  @ObservationIgnored fileprivate var timeReachedTop: TimeInterval = 0
  @ObservationIgnored private var isActive: Bool = true
  
  public init(scrollThreshold: CGFloat? = nil, showScrollIndicator: Bool = false) {
    self.scrollThreshold = scrollThreshold
    self.showScrollIndicator = showScrollIndicator
  }
  
  public var overscroll: CGFloat = 0
  
  public var hasScrolled: Bool = false// { scrollOffset < scrollThreshold }
  
  public var scrollThresholdProgress: Double { min(1, max(0, scrollOffset / min(-0.01, effectiveScrollThreshold))) }
  
  public func scroll(to scrollTarget: HelloScrollTarget, animated: Bool = false) {
    scroll(to: scrollTarget, animation: animated ? .easeOut(duration: 0.5) : nil)
  }
  
  public func scroll(to scrollTarget: HelloScrollTarget, animation: Animation?) {
    scrollAnimation = animation
    self.scrollTarget = scrollTarget
  }
  
  public func setActive(_ isActive: Bool) {
    self.isActive = isActive
  }
  
  public func resetDismissState() {
    isDismissed = false
  }
  
  fileprivate func update(offset: CGFloat) {
    guard isActive else { return }
    if offset < 0 {
      timeReachedTop = epochTime
    }

    if readyForDismiss
        && !isDismissing
        && offset > scrollOffset {
      isDismissing = true
    }
    
    if !readyForDismiss
        && offset >= 0 && offset < scrollOffset
        && epochTime - timeReachedTop > 0.1 {
      readyForDismiss = true
    } else if readyForDismiss && offset < 0 {
      readyForDismiss = false
      isDismissing = false
    }
    
    guard scrollOffset != offset else { return }
    scrollOffset = offset
    let hasScrolled = scrollOffset < effectiveScrollThreshold
    if self.hasScrolled != hasScrolled {
      self.hasScrolled = hasScrolled
    }
    
    if scrollOffset > 0 {
      overscroll = scrollOffset
    } else if overscroll != 0 {
      overscroll = 0
    }
    
    #if os(iOS)
    if !isDismissed && dismissProgress == 1 && TouchesModel.main.activeTouches.isEmpty {
      isDismissed = true
    }
    #endif
    
    if isDismissing {
      let newDismissProgress = min(1, max(0, offset / 100))
      guard dismissProgress != newDismissProgress else { return }
      dismissProgress = newDismissProgress
      
      #if !os(iOS)
      if !isDismissed && dismissProgress == 1 {
        isDismissed = true
      }
      #endif
    } else if dismissProgress != 0 {
      dismissProgress = 0
    }
  }
}

@MainActor
public struct HelloScrollView<Content: View>: View {
  
  @Environment(\.theme) private var theme
  
  @State private var model: HelloScrollModel
  
  private let allowScroll: Bool
  private var content: () -> Content
  
  public init(allowScroll: Bool = true,
              model: HelloScrollModel? = nil,
              @ViewBuilder content: @escaping () -> Content) {
    self.allowScroll = allowScroll
    self.content = content
    _model = State(wrappedValue: model ?? HelloScrollModel())
  }
  
  public var body: some View {
    ScrollViewReader { scrollView in
      ScrollView(allowScroll ? .vertical : [], showsIndicators: model.showScrollIndicator) {
        VStack(spacing: 0) {
          PositionReaderView(onPositionChange: { model.update(offset: $0.y) },
                             coordinateSpace: .named(model.coordinateSpaceName))
            .frame(height: 0)
          content()
          Color.clear.frame(height: 0)
            .id(HelloScrollTarget.bottom.id)
        }.id(HelloScrollTarget.top.id)
      }.coordinateSpace(name: model.coordinateSpaceName)
        .insetBySafeArea()
        .onChange(of: model.scrollTarget) {
          guard let scrollTarget = model.scrollTarget else { return }
          model.scrollTarget = nil
          withAnimation(model.scrollAnimation) {
            scrollView.scrollTo(scrollTarget.id, anchor: .top)
          }
        }
    }.environment(model)
  }
}

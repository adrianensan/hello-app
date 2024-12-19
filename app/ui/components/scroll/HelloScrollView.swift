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

public enum HelloScrollAxes: Hashable, Sendable {
  case vertical
  case horizontal
  case both
  case none
  
  public var isVertical: Bool {
    switch self {
    case .vertical, .both: true
    case .horizontal, .none: false
    }
  }
  
  public var isHorizontal: Bool {
    switch self {
    case .horizontal, .both: true
    case .vertical, .none: false
    }
  }
  
  public var swiftui: Axis.Set {
    switch self {
    case .vertical: [.vertical]
    case .horizontal: [.horizontal]
    case .both: [.vertical, .horizontal]
    case .none: []
    }
  }
}

@MainActor
@Observable
public class HelloScrollModel {
  
  fileprivate var scrollTarget: HelloScrollTarget?
  var swiftuiScrollPosition = ScrollPosition()
  
  public fileprivate(set) var scrollOffset: CGFloat = 0
  public fileprivate(set) var dismissProgress: CGFloat = 0
  public fileprivate(set) var isDismissed: Bool = false
  public fileprivate(set) var showScrollIndicator: Bool
  public let invertScroll: Bool
  
  public var scrollThreshold: CGFloat?
  var defaultScrollThreshold: CGFloat = 0
  
  public var effectiveScrollThreshold: CGFloat { scrollThreshold ?? defaultScrollThreshold }
  
  public let id: String = .uuid
  public var axes: HelloScrollAxes
  fileprivate let coordinateSpaceName: String = .uuid
  @ObservationIgnored internal private(set) var readyForDismiss: Bool = true
  @ObservationIgnored fileprivate var isDismissing: Bool = true
  @ObservationIgnored fileprivate var timeReachedTop: TimeInterval = 0
  @ObservationIgnored private var isScreenTouched: Bool = false
  @ObservationIgnored private var isActive: Bool = true
//  @ObservationIgnored private var lastUpdate: TimeInterval = epochTime
  
  public init(axes: HelloScrollAxes = .vertical,
              scrollThreshold: CGFloat? = nil,
              showScrollIndicator: Bool = false,
              invertScroll: Bool = false) {
    self.axes = axes
    self.scrollThreshold = scrollThreshold
    self.showScrollIndicator = showScrollIndicator
    self.invertScroll = invertScroll
  }
  
  public var scrollEnabled: Bool = true
  public var scrollBottomOffset: CGFloat = 0
  
  public var overscroll: CGFloat = 0
  
  public var hasScrolled: Bool = false
  
  public var scrollThresholdProgress: Double { min(1, max(0, scrollOffset / min(-0.01, effectiveScrollThreshold))) }
  
  public func scroll(to scrollTarget: HelloScrollTarget, animated: Bool = false) {
    scroll(to: scrollTarget, animation: animated ? .easeOut(duration: 0.5) : nil)
  }
  
  public func scroll(to scrollTarget: HelloScrollTarget, animation: Animation?) {
    withAnimation(animation) {
      switch scrollTarget {
      case .top:
        swiftuiScrollPosition.scrollTo(edge: .top)
      case .bottom:
        swiftuiScrollPosition.scrollTo(edge: .bottom)
      case .view(let id):
        swiftuiScrollPosition.scrollTo(id: id)
      }
    }
  }
  
  public func setActive(_ isActive: Bool) {
    self.isActive = isActive
  }
  
  public func setIsTouching(_ isTouching: Bool) {
    self.isScreenTouched = isTouching
  }
  
  public func resetDismissState() {
    isDismissed = false
  }
  
  fileprivate func update(offset: CGFloat) {
//    let time: TimeInterval = epochTime
//    lastUpdate = time
    guard isActive else { return }
    
    if readyForDismiss
        && !isDismissing
        && offset > scrollOffset {
      isDismissing = true
    }
    
    if offset > scrollOffset {
      timeReachedTop = epochTime
    }
    
    if !readyForDismiss
        && offset >= 0
        && epochTime - timeReachedTop >= 0 {
      let diff = 0.3 - (epochTime - timeReachedTop)
      if diff > 0 {
        Task {
          try await Task.sleep(seconds: diff)
          guard !readyForDismiss && offset >= 0 && epochTime - timeReachedTop >= 0.3 else { return }
          readyForDismiss = true
        }
      } else {
        readyForDismiss = true
      }
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
    if !isDismissed && dismissProgress == 1 && !isScreenTouched {
      isDismissed = true
    }
    #endif
    
    if isDismissing {
      let newDismissProgress = min(1, max(0, offset / 100))
      guard dismissProgress != newDismissProgress else { return }
      dismissProgress = newDismissProgress
    } else if dismissProgress != 0 {
      dismissProgress = 0
    }
  }
}

public struct HelloScrollView<Content: View>: View {
  
  @Environment(\.pageID) private var pageID
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeAreaInsets
  @OptionalEnvironment(HelloPagerModel.self) private var pagerModel
  
  @State private var model: HelloScrollModel
  
  private var content: @MainActor () -> Content
  
  public init(axes: HelloScrollAxes = .vertical,
              invertScroll: Bool = false,
              @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.content = content
    _model = State(initialValue: HelloScrollModel(axes: axes, invertScroll: invertScroll))
  }
  
  public init(model: HelloScrollModel,
              @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.content = content
    _model = State(initialValue: model)
  }
  
  public var body: some View {
    ScrollView(model.axes.swiftui, showsIndicators: model.showScrollIndicator) {
      VStack(spacing: 0) {
        GeometryReader { geometry in
          let _ = model.update(offset: geometry.frame(in: .named(model.coordinateSpaceName)).origin.y)
          Color.clear
        }.frame(height: 0)
        content()
      }
    }.coordinateSpace(name: model.coordinateSpaceName)
      .safeAreaInset(edge: .top, spacing: 0) {
      Color.clear.frame(height: safeAreaInsets.top)
    }.safeAreaInset(edge: .bottom, spacing: 0) {
      Color.clear.frame(height: safeAreaInsets.bottom)
    }.safeAreaInset(edge: .leading, spacing: 0) {
      Color.clear.frame(width: safeAreaInsets.leading)
    }.safeAreaInset(edge: .trailing, spacing: 0) {
      Color.clear.frame(width: safeAreaInsets.trailing)
    }.if(model.invertScroll) {
      $0.defaultScrollAnchor(.bottomLeading, for: .sizeChanges)
        .defaultScrollAnchor(.bottomLeading, for: .initialOffset)
    }.scrollBounceBehavior(.basedOnSize, axes: .horizontal)
      .scrollDisabled(!model.scrollEnabled)
      .modifier(HelloScrollPositionViewModifier())
      .modifier(HelloScrollTouchViewModifier())
    //      .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
    //        -geometry.contentOffset.y - geometry.contentInsets.top
    //      }, action: { _, newScrollOffset in
    //        model.update(offset: newScrollOffset)
    //      })
      .environment(model)
      .onChange(of: pageID, initial: true) {
        if let pageID {
          pagerModel?.set(scrollModel: model, for: pageID)
        }
      }
  }
}

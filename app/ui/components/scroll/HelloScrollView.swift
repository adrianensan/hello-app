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
  var swiftuiScrollPosition = ScrollPosition()
  
  public fileprivate(set) var scrollOffset: CGFloat = 0
  public fileprivate(set) var dismissProgress: CGFloat = 0
  public fileprivate(set) var isDismissed: Bool = false
  public fileprivate(set) var showScrollIndicator: Bool
  
  public var scrollThreshold: CGFloat?
  var defaultScrollThreshold: CGFloat = 0
  
  public var effectiveScrollThreshold: CGFloat { scrollThreshold ?? defaultScrollThreshold }
  
  fileprivate let coordinateSpaceName: String = .uuid
  @ObservationIgnored internal private(set) var readyForDismiss: Bool = true
  @ObservationIgnored fileprivate var isDismissing: Bool = true
  @ObservationIgnored fileprivate var timeReachedTop: TimeInterval = 0
  @ObservationIgnored private var isActive: Bool = true
//  @ObservationIgnored private var lastUpdate: TimeInterval = epochTime
  
  public init(scrollThreshold: CGFloat? = nil, showScrollIndicator: Bool = false) {
    self.scrollThreshold = scrollThreshold
    self.showScrollIndicator = showScrollIndicator
  }
  
  public var scrollEnabled: Bool = true
  public var scrollBottomOffset: CGFloat = 0
  
  #if os(iOS)
  public var isScreenTouched: Bool { !TouchesModel.main.activeTouches.isEmpty }
  #else
  public var isScreenTouched: Bool { false }
  #endif
  
  public var overscroll: CGFloat = 0
  
  public var hasScrolled: Bool = false// { scrollOffset < scrollThreshold }
//  public var hasScrolledDuringTouch: Bool = false
  
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
    
    if !readyForDismiss
        && offset >= 0
        && epochTime - timeReachedTop > 0.3 {
      readyForDismiss = true
    } else if readyForDismiss && offset < 0 {
      readyForDismiss = false
      isDismissing = false
    }
    
    if offset > scrollOffset {
      timeReachedTop = epochTime
    }
    
//    #if os(iOS)
//    if !isScreenTouched {
//      TouchesModel.main.hasScrolledDuringTouch = false
//    }
//    #endif
    
    guard scrollOffset != offset else { return }
    scrollOffset = offset
//    #if os(iOS)
//    TouchesModel.main.hasScrolledDuringTouch = isScreenTouched
//    #endif
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

public struct HelloScrollView<Content: View>: View {
  
  @Environment(\.pageID) private var pageID
  @Environment(\.theme) private var theme
  @OptionalEnvironment(PagerModel.self) private var pagerModel
  
  @State private var model: HelloScrollModel
  
  private let allowScroll: Bool
  private var content: @MainActor () -> Content
  
  public init(allowScroll: Bool = true,
              model: HelloScrollModel? = nil,
              @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.allowScroll = allowScroll
    self.content = content
    _model = State(initialValue: model ?? HelloScrollModel())
  }
  
  public var body: some View {
    ScrollView(allowScroll ? .vertical : [], showsIndicators: model.showScrollIndicator) {
      VStack(spacing: 0) {
        GeometryReader { geometry in
          let _ = model.update(offset: geometry.frame(in: .named(model.coordinateSpaceName)).origin.y)
          Color.clear
        }.frame(height: 0)
        content()
      }
    }.scrollDisabled(!model.scrollEnabled)
      .modifier(HelloScrollPositionViewModifier())
    //      .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
    //        -geometry.contentOffset.y - geometry.contentInsets.top
    //      }, action: { _, newScrollOffset in
    //        model.update(offset: newScrollOffset)
    //      })
      .coordinateSpace(name: model.coordinateSpaceName)
      .insetBySafeArea()
      .environment(model)
      .onChange(of: pageID, initial: true) {
        if let pageID {
          pagerModel?.set(scrollModel: model, for: pageID)
        }
      }
  }
}

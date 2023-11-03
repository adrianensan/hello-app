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
  
  public init() {
    
  }
  
  public var overscroll: CGFloat { max(0, scrollOffset) }
  
  public var hasScrolled: Bool { scrollOffset < 0 }
  
  public func scroll(to scrollTarget: HelloScrollTarget) {
    self.scrollTarget = scrollTarget
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
  
  private func update(offset: CGFloat) {
    Task {
      if offset < 0 {
        model.timeReachedtop = Date().timeIntervalSince1970
      }
      
      if model.readyForDismiss
          && !model.isDismissing
          && offset > model.scrollOffset {
        model.isDismissing = true
      }
      
      if !model.readyForDismiss
          && offset >= 0 && offset < model.scrollOffset
          && Date().timeIntervalSince1970 - model.timeReachedtop > 0.1 {
        model.readyForDismiss = true
      } else if model.readyForDismiss && offset < 0 {
        model.readyForDismiss = false
        model.isDismissing = false
      }
      
      guard model.scrollOffset != offset else { return }
      model.scrollOffset = offset
      
      if model.isDismissing {
        let newDismissProgress = min(1, max(0, offset / 100))
        guard model.dismissProgress != newDismissProgress else { return }
        model.dismissProgress = newDismissProgress
      } else if model.dismissProgress != 0 {
        model.dismissProgress = 0
      }
    }
  }
  
  public var body: some View {
    ScrollViewReader { scrollView in
      ScrollView(allowScroll ? .vertical : [], showsIndicators: showsIndicators) {
        VStack(spacing: 0) {
          PositionReaderView(onPositionChange: { update(offset: $0.y) },
                             coordinateSpace: .named(model.coordinateSpaceName))
          .frame(height: 0)
          content
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

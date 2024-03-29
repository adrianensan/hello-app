import SwiftUI

import HelloCore

public extension Alignment {
  var unitPoint: UnitPoint {
    var x, y: CGFloat
    switch horizontal {
    case .leading: x = 0
    case .center: x = 0.5
    case .trailing: x = 1
    default: x = 0.5
    }
    
    switch vertical {
    case .top: y = 0
    case .center: y = 0.5
    case .bottom: y = 1
    default: y = 0.5
    }
    
    return UnitPoint(x: x, y: y)
  }
  
  public var point: CGPoint {
    CGPoint(x: unitPoint.x, y: unitPoint.y)
  }
}

public struct PopupViewWrapper<Content: View>: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.safeArea) private var safeArea
  
  @State private var isVisible: Bool
  
  private var content: (Binding<Bool>) -> Content
  private var position: CGPoint
  private var size: CGSize?
  private var anchor: Alignment
  
  public init(position: CGPoint, size: CGSize? = nil, anchor: Alignment, @ViewBuilder content: @escaping (Binding<Bool>) -> Content) {
    let isVisible = State(initialValue: false)
    self._isVisible = isVisible
    self.content = content
    self.position = position
    self.size = size
    self.anchor = anchor
  }
  
  private var adjustedPosition: CGPoint {
    if let size {
      var position = position
      let minWindowEdgeDistances = position - anchor.point * size - CGPoint(x: 8, y: safeArea.top + 8)
      if minWindowEdgeDistances.x < 0 {
        position.x -= minWindowEdgeDistances.x
      }
      if minWindowEdgeDistances.y < 0 {
        position.y -= minWindowEdgeDistances.y
      }
      
      let maxWindowEdgeDistances = position + (.one - anchor.point) * size + CGPoint(x: 8, y: safeArea.bottom + 8)
      if maxWindowEdgeDistances.x > windowFrame.width {
        position.x -= maxWindowEdgeDistances.x - windowFrame.width
      }
      if maxWindowEdgeDistances.y > windowFrame.height {
        position.y -= maxWindowEdgeDistances.y - windowFrame.height
      }
      return position
    } else {
      return position
    }
  }
  
  public var body: some View {
    content($isVisible)
      .frame(alignment: .center)
      .fixedSize()
      .scaleEffect(isVisible ? 1 : 0.1, anchor: anchor.unitPoint)
      .frame(width: 1, height: 1, alignment: anchor)
      .compositingGroup()
      .opacity(isVisible ? 1 : 0)
      .animation(isVisible ? .dampSpring : .easeInOut(duration: 0.25), value: isVisible)
      .offset(adjustedPosition)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .background(Color.black
        .opacity(isVisible ? 0.2 : 0)
        .nest {
          #if os(tvOS)
          $0
          #else
          $0.onLongPressGesture(minimumDuration: 0, maximumDistance: 0) {
            guard isVisible else { return }
            isVisible = false
          }
          #endif
        }.animation(.easeInOut(duration: 0.2), value: isVisible))
      .allowsHitTesting(isVisible)
      .onAppear {
        guard !isVisible else { return }
        isVisible = true
      }.onChange(of: isVisible) {
        if !$0 {
          windowModel.dismissPopup()
        }
      }
  }
}

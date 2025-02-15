#if os(iOS)
import SwiftUI

import HelloCore

public struct HelloPickerPopupViewWrapper<Content: View>: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.safeArea) private var safeArea
  @Environment(\.popupID) private var viewID
  @Environment(\.viewID) private var uniqueViewID
  @Environment(\.theme) private var theme
  
  @State private var isVisible: Bool = false
  
  private var content: (Binding<Bool>) -> Content
  private var position: CGPoint
  private var size: CGSize
  @Binding private var startIndex: Int
  
  public init(position: CGPoint,
              size: CGSize,
              startIndex: Binding<Int>,
              @ViewBuilder content: @escaping (Binding<Bool>) -> Content) {
    self.content = content
    self.position = position
    self.size = size
    _startIndex = startIndex
  }
  
  private var adjustedPosition: CGPoint {
    var position = position
    position.x -= 2
    position.y -= CGFloat(startIndex) * HelloPickerSizing.expandedRowHeight
    let anchor = Alignment.topLeading
    let minWindowEdgeDistances = position - anchor.point * size - CGPoint(x: 8, y: safeArea.top + 8)
    if minWindowEdgeDistances.y < 0 {
      position.y -= minWindowEdgeDistances.y
    }
    
    let maxWindowEdgeDistances = position + (.one - anchor.point) * size + CGPoint(x: 8, y: safeArea.bottom + 8)
    if maxWindowEdgeDistances.y > windowFrame.height {
      position.y -= maxWindowEdgeDistances.y - windowFrame.height
    }
    return position
  }
  
  var diff: CGFloat {
    0.5 * (HelloPickerSizing.expandedRowHeight - HelloPickerSizing.collapsedRowHeight)
  }
  
  public var body: some View {
    content($isVisible)
      .background(theme.surfaceSection.backgroundView(for: RoundedRectangle(cornerRadius: 12, style: .continuous), isBaseLayer: true))
      .offset(y: isVisible ? 0 : -(CGFloat(startIndex) * HelloPickerSizing.expandedRowHeight + diff))
      .frame(height: isVisible ? size.height : HelloPickerSizing.collapsedRowHeight, alignment: .topLeading)
      .clipShape(RoundedRectangle(cornerRadius: isVisible ? 16 : 10, style: .continuous))
      .overlay(RoundedRectangle(cornerRadius: isVisible ? 16 : 10, style: .continuous)
        .strokeBorder(theme.surfaceSection.backgroundOutline, lineWidth: theme.surfaceSection.backgroundOutlineWidth))
      .offset(y: isVisible ? 0 : diff)
      .compositingGroup()
      .animation(.pageAnimation, value: isVisible)
      .offset(isVisible ? adjustedPosition : position)
      .environment(\.helloDismiss, { isVisible = false })
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .background(HelloBackgroundDimmingView()
        .opacity(isVisible ? 0.5 : 0)
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
      }.when(!isVisible) {
#if os(iOS)
        windowModel.markDismiss(id: uniqueViewID)
#endif
        Task {
          try? await Task.sleep(seconds: 0.24)
          if let viewID {
            windowModel.dismiss(id: viewID)
          } else {
            windowModel.dismissPopup()
          }
        }
      }
  }
}
#endif

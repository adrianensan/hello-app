import SwiftUI

extension Alignment {
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
}

public struct PopupViewWrapper<Content: View>: View {
  
  @EnvironmentObject private var windowModel: HelloWindowModel
  @EnvironmentObject private var uiProperties: UIProperties
  
  @State private var isVisible: Bool
  
  private var content: (Binding<Bool>) -> Content
  private var position: CGPoint
  private var anchor: Alignment
  
  public init(position: CGPoint, anchor: Alignment, @ViewBuilder content: @escaping (Binding<Bool>) -> Content) {
    let isVisible = State(initialValue: false)
    self._isVisible = isVisible
    self.content = content
    self.position = position
    self.anchor = anchor
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
      .offset(x: position.x, y: position.y)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .background(Color.black
        .opacity(isVisible ? 0.2 : 0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 0) {
          guard isVisible else { return }
          isVisible = false
        }
        .animation(.easeInOut(duration: 0.2), value: isVisible))
      .allowsHitTesting(isVisible)
      .onAppear {
        guard !isVisible else { return }
        isVisible = true
      }.onChange(of: isVisible) {
        if !$0 {
          windowModel.dismissPopup()
        }
      }.onChange(of: uiProperties.size) { _ in
        guard isVisible else { return }
        isVisible = false
      }
  }
}

import SwiftUI

public struct HelloSheet<Content: View>: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.safeArea) private var safeArea
  
  @State private var isVisible: Bool
  @GestureState private var drag: CGSize = .zero
  
  private var content: (Binding<Bool>) -> Content
  
  public init(@ViewBuilder content: @escaping (Binding<Bool>) -> Content) {
    let isVisible = State(initialValue: false)
    self._isVisible = isVisible
    self.content = content
  }
  
  private var yDrag: CGFloat {
    if drag.height < 0 {
      0.06 * drag.height
    } else {
      drag.height
    }
  }
  
  public var body: some View {
    content($isVisible)
      .compositingGroup()
      .frame(height: isVisible ? nil : 1, alignment: .top)
      .animation(isVisible ? .dampSpring : .easeInOut(duration: 0.25), value: isVisible)
      .offset(y: isVisible ? yDrag : 8)
      .animation(.interactive, value: yDrag)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
      .background(Color.black
        .opacity(isVisible ? 0.2 : 0)
        .nest {
#if os(tvOS)
          $0
#else
          $0.onTapGesture {
            isVisible = false
          }
#endif
        }.animation(.easeInOut(duration: 0.2), value: isVisible))
      .gesture(DragGesture(minimumDistance: 1, coordinateSpace: .named("sheet"))
        .updating($drag) { value, state, transaction in
          state = value.translation
        }.onEnded { gesture in
          if gesture.predictedEndTranslation.height > 200 {
            isVisible = false
          }
        })
      .allowsHitTesting(isVisible)
      .onAppear {
        guard !isVisible else { return }
        isVisible = true
      }.onChange(of: isVisible) {
        if !$0 {
          windowModel.dismissPopup()
        }
      }.transformEnvironment(\.safeArea) { $0.top = Device.currentEffective.screenCornerRadius }
  }
}

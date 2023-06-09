import SwiftUI

struct DrawingGroupRedraw<Value: Equatable>: ViewModifier {
  
  @State var id: String = UUID().uuidString
  var value: Value
  
  func body(content: Content) -> some View {
    content
      .id(id)
      .drawingGroup()
      .onChange(of: value) { _ in
        id = UUID().uuidString
      }
  }
}

public extension View {
  func drawingGroup<Value: Equatable>(redrawFforChangeOf value: Value) -> some View {
    modifier(DrawingGroupRedraw(value: value))
  }
}

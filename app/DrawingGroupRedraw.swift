import SwiftUI

struct DrawingGroupRedraw<Value: Equatable>: ViewModifier {
  
  @State var id: String = .uuid
  var value: Value
  
  func body(content: Content) -> some View {
    content
      .id(id)
      .drawingGroup()
      .onChange(of: value) {
        id = .uuid
      }
  }
}

public extension View {
  func drawingGroup<Value: Equatable>(redrawFforChangeOf value: Value) -> some View {
    modifier(DrawingGroupRedraw(value: value))
  }
}

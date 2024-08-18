import SwiftUI

struct HelloScrollPositionViewModifier: ViewModifier {
  
  @Environment(HelloScrollModel.self) private var scrollModel
  
  func body(content: Content) -> some View {
    @Bindable var scrollModel = scrollModel
    content.scrollPosition($scrollModel.swiftuiScrollPosition)
  }
}

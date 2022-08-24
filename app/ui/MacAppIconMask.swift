import SwiftUI

public struct MacAppIconWrapperView<Content: View>: View {
  
  var view: Content
  
  public init(_ content: @autoclosure () -> Content) {
    self.view = content()
  }
  
  public var body: some View {
    GeometryReader { geometry in
      view
        .clipShape(AppIconShape())
        .padding(0.05 * geometry.size.minSide)
    }
  }
}

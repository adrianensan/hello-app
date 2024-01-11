import SwiftUI

public struct IOSAppIconWrapperView<Content: View>: View {
  
  @Environment(\.theme) var theme
  
  var isSmall: Bool
  
  var view: () -> Content
  
  public init(isSmall: Bool, _ content: @autoclosure @escaping () -> Content) {
    self.isSmall = isSmall
    self.view = content
  }
  
  public var body: some View {
    view()
      .clipShape(AppIconShape())
      .frame(width: isSmall ? 32 : 60, height: isSmall ? 32 : 60)
      .overlay(AppIconShape().stroke(theme.text.primary.color.opacity(0.1), lineWidth: 1))
  }
}

import SwiftUI

struct ApplyThemeViewModifier: ViewModifier {
  
  @Environment(\.theme) private var theme
  @Environment(\.hasAppliedTheme) private var hasAppliedTheme
  
  func body(content: Content) -> some View {
    content
      .fontDesign(theme.base.fontDesign)
      .font(theme.font(size: 16, weight: .regular))
      .foregroundStyle(theme.foreground.primary.style)
      .backgroundStyle(theme.backgroundColor)
      .background(theme.backgroundColor)
      .environment(\.hasAppliedTheme, ["crt-light", "crt-dark"].contains(theme.theme.id))
      .environment(\.colorScheme, theme.theme.scheme == .dark ? .dark : .light)
      .overlay {
        if !hasAppliedTheme {
          switch theme.theme.id {
          case "crt-light", "crt-dark":
            GeometryReader { geometry in
              let rows = Int(geometry.size.height / 2)
              Path { path in
                for row in 0...rows {
                  path.move(to: CGPoint(x: 0, y: CGFloat(row) * 2))
                  path.addLine(to: CGPoint(x: geometry.size.width, y: CGFloat(row) * 2))
                }
                path.move(to: CGPoint(x: 0, y: 0))
              }.stroke(.black, lineWidth: 1)
            }.allowsHitTesting(false)
          default: EmptyView()
          }
        }
      }
  }
}

public extension View {
  func applyTheme() -> some View {
    self.modifier(ApplyThemeViewModifier())
  }
}

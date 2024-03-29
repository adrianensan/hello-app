import SwiftUI

import HelloCore

public struct HelloSectionItem<Content: View>: View {
  
  @Environment(\.theme) private var theme

  private var content: () -> Content
  
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    content()
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .frame(maxWidth: .infinity, minHeight: 56)
      .background(theme.surface.backgroundColor)
      .overlay {
        theme.foreground.primary.color.opacity(0.1)
          .padding(.leading, 52)
          .frame(height: 1)
          .offset(y: -1)
          .frame(maxHeight: .infinity, alignment: .top)
      }
  }
}

public struct HelloSection<Content: View>: View {
  
  @Environment(\.theme) private var theme
  
  private var content: () -> Content
  
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    content()
      .background(theme.surface.backgroundView(for: .rect(cornerRadius: 16), isBaseLayer: true))
      .clipShape(.rect(cornerRadius: 16))
      .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
        .stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
      .frame(maxWidth: 520)
  }
}

public struct HelloTitledSection<Content: View>: View {
  
  @Environment(\.theme) private var theme
  
  private var title: String
  private var content: () -> Content
  
  public init(title: String, @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.content = content
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.system(size: 13, weight: .regular, design: .rounded))
        .foregroundStyle(theme.foreground.tertiary.style)
        .fixedSize()
        .padding(.horizontal, 4)
      
      HelloSection {
        content()
      }
    }.frame(maxWidth: 520)
  }
}

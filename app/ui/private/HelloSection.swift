import SwiftUI

import HelloCore

public struct HelloSectionItem<Content: View>: View {
  
  @Environment(\.theme) private var theme

  private var content: @MainActor () -> Content
  private var leadingPadding: Bool
  
  public init(leadingPadding: Bool = true, @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.content = content
    self.leadingPadding = leadingPadding
  }
  
  public var body: some View {
    content()
      .padding(.leading, 14)
      .padding(.trailing, 12)
      .padding(.vertical, 12)
      .foregroundStyle(theme.surface.foreground.primary.style)
      .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
      .background(theme.surface.backgroundColor)
      .overlay {
        theme.surface.foreground.primary.color.opacity(0.1)
          .padding(.leading, leadingPadding ? 52 : 0)
          .frame(height: 1)
          .offset(y: -1)
          .frame(maxHeight: .infinity, alignment: .top)
      }
  }
}

//public struct HelloSection<Content: View>: View {
//  
//  @Environment(\.theme) private var theme
//  
//  private var content: () -> Content
//  
//  public init(@ViewBuilder content: @escaping () -> Content) {
//    self.content = content
//  }
//  
//  public var body: some View {
//    VStack(alignment: .leading, spacing: 0) {
//      content()
//    }.background(theme.surface.backgroundView(for: .rect(cornerRadius: 16), isBaseLayer: true))
//      .clipShape(.rect(cornerRadius: 16))
//      .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
//        .stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
//      .frame(maxWidth: 520)
//  }
//}

public struct HelloSection<Content: View>: View {
  
  @Environment(\.theme) private var theme
  
  private var title: String?
  @ViewBuilder private var content: @MainActor () -> Content
  
  public init(title: String? = nil, @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.title = title
    self.content = content
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      if let title {
        Text(title)
          .font(.system(size: 13, weight: .regular, design: .rounded))
          .foregroundStyle(theme.foreground.tertiary.style)
          .fixedSize()
          .padding(.horizontal, 4)
      }
      
      VStack(alignment: .leading, spacing: 0) {
        content()
      }.background(theme.surface.backgroundView(for: .rect(cornerRadius: 16), isBaseLayer: true))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
          .stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
        .frame(maxWidth: 520)
    }.frame(maxWidth: 520)
  }
}

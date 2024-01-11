import SwiftUI

import HelloCore

public struct HelloSection<Content: View>: View {
  
  @Environment(\.theme) private var theme

  private var content: () -> Content
  
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    content()
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(theme.surface.backgroundView(for: .rect(cornerRadius: 16)))
      .frame(maxWidth: 520)
  }
}

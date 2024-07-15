import SwiftUI

import HelloCore

public struct HelloMenuItem: Identifiable {
  public var id: String = UUID().uuidString
  var name: String
  var icon: String
  var action: @MainActor () -> Void
  
  public init(id: String = UUID().uuidString, 
              name: String, 
              icon: String, 
              action: @MainActor @escaping () -> Void) {
    self.id = id
    self.name = name
    self.icon = icon
    self.action = action
  }
}

public struct HelloMenu: View {
  
  @Environment(\.theme) private var theme
  
  var position: CGPoint
  var anchor: Alignment = .topTrailing
  var items: [HelloMenuItem]
  
  public init(position: CGPoint,
              anchor: Alignment = .topTrailing,
              items: [HelloMenuItem]) {
    self.position = position
    self.anchor = anchor
    self.items = items
  }
  
  public var body: some View {
    PopupViewWrapper(position: position,
                     size: CGSize(width: 240, height: CGFloat(items.count) * 44),
                     anchor: anchor) { isVisible in
      VStack(spacing: 0) {
        ForEach(items) { item in
          Button(action: {
            isVisible.wrappedValue = false
            item.action()
            ButtonHaptics.buttonFeedback()
          }) {
            HStack(spacing: 0) {
              Text(item.name)
                .lineLimit(1)
              Spacer(minLength: 4)
              Image(systemName: item.icon)
                .frame(width: 18)
            }.font(.system(size: 14, weight: .medium, design: .rounded))
              .foregroundColor(theme.foreground.primary.color)
              .padding(.horizontal, 12)
              .frame(width: 240, height: 44)
              .background(theme.backgroundView(isBaseLayer: true))
          }.buttonStyle(.highlight)
            .overlay {
              theme.text.primary.color.opacity(0.1)
                .frame(height: 1)
                .offset(y: -1)
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
      }.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .background(theme.floating.backgroundView(for: RoundedRectangle(cornerRadius: 12, style: .continuous)))
    }
  }
}

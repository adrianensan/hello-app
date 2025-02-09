import SwiftUI

public struct HelloPickerPopupRow<Item: HelloPickerItem, Content: View>: View {
  
  @Environment(\.theme) private var theme
  
  var item: Item
  var isSelected: Bool
  var isExpanded: Bool
  var content: @MainActor (Item) -> Content

  public var body: some View {
    HStack(spacing: 0) {
      ZStack {
        Image(systemName: "checkmark")
          .opacity(isSelected && isExpanded ? 1 : 0)
        Image(systemName: "chevron.up.chevron.down")
          .opacity(isSelected && !isExpanded ? 1 : 0)
          .foregroundStyle(theme.surfaceSection.foreground.tertiary.color)
      }.frame(width: 32)
      content(item)
        .lineLimit(1)
      Spacer(minLength: 0)
    }.font(.system(size: 16, weight: .regular))
      .foregroundStyle(theme.surfaceSection.foreground.primary.color)
      .padding(.trailing, 4)
      .frame(maxWidth: .infinity)
      .frame(height: 44)
      .overlay {
        theme.text.primary.color.opacity(0.1)
          .frame(height: 1)
          .offset(y: -1)
          .frame(maxHeight: .infinity, alignment: .top)
      }
  }
}

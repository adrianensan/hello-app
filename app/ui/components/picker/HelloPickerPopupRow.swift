import SwiftUI

public struct HelloPickerPopupRow: View {
  
  @Environment(\.theme) private var theme
  
  var item: HelloPickerPopupItem
  var isSelected: Bool
  var isExpanded: Bool
  
  public var body: some View {
    HStack(spacing: 0) {
      Image(systemName: isExpanded ? "checkmark" : "chevron.up.chevron.down")
      //        .contentTransition(.symbolEffect(.replace))
        .frame(width: 32)
        .opacity(isSelected ? 1 : 0)
      Text(item.name)
        .lineLimit(1)
      Spacer(minLength: 0)
    }.font(.system(size: 16, weight: .regular))
      .foregroundColor(theme.surfaceSection.foreground.primary.color)
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

#if os(iOS)
import SwiftUI

public struct HelloPickerPopup<Item: HelloPickerItem, ItemContent: View>: View {
  
  public static var collapsedRowHeight: CGFloat { 40 }
  public static var expandedRowHeight: CGFloat { 44 }
  
  @Environment(\.theme) private var theme
  
  private var position: CGPoint
  private var anchor: Alignment = .topTrailing
  private var items: [Item]
  @State private var selectedItemID: String
  private var width: CGFloat
  private var onChange: @MainActor (Item) -> Void
  private var content: @MainActor (Item) -> ItemContent

  public init(position: CGPoint,
              anchor: Alignment = .topTrailing,
              items: [Item],
              selectedItemID: String,
              width: CGFloat,
              onChange: @escaping @MainActor (Item) -> Void,
              content: @escaping @MainActor (Item) -> ItemContent
  ) {
    self.position = position
    self.anchor = anchor
    self.items = items
    _selectedItemID = State(initialValue: selectedItemID)
    self.width = width
    self.onChange = onChange
    self.content = content
  }
  
  public var body: some View {
    HelloPickerPopupViewWrapper(
      position: position,
      size: CGSize(width: width, height: CGFloat(items.count) * HelloPickerPopup.expandedRowHeight),
      startIndex: Binding(get: { items.firstIndex { $0.id == selectedItemID } ?? 0 },
                          set: { _ in })
    ) { isVisible in
      VStack(spacing: 0) {
        ForEach(items) { item in
          HelloButton(clickStyle: .highlight, action: {
            selectedItemID = item.id
            isVisible.wrappedValue = false
            onChange(item)
          }) {
            HelloPickerPopupRow(item: item,
                                isSelected: item.id == selectedItemID,
                                isExpanded: isVisible.wrappedValue,
                                content: content)
              .padding(.horizontal, isVisible.wrappedValue ? 2 : 0)
          }.buttonShape(.rect)
        }
      }.frame(width: width + (isVisible.wrappedValue ? 4 : 0))
    }
  }
}
#endif

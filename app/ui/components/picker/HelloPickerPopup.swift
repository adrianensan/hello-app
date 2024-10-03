import SwiftUI

public struct HelloPickerPopup: View {
  
  public static var collapsedRowHeight: CGFloat { 40 }
  public static var expandedRowHeight: CGFloat { 44 }
  
  @Environment(\.theme) private var theme
  
  private var position: CGPoint
  private var anchor: Alignment = .topTrailing
  private var items: [HelloPickerPopupItem]
  @State private var selectedItemID: String
  private var width: CGFloat
  
  public init(position: CGPoint,
              anchor: Alignment = .topTrailing,
              items: [HelloPickerPopupItem],
              selectedItemID: String,
              width: CGFloat) {
    self.position = position
    self.anchor = anchor
    self.items = items
    _selectedItemID = State(initialValue: selectedItemID)
    self.width = width
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
            //            try? await Task.sleepForOneFrame()
            isVisible.wrappedValue = false
            try await item.action()
          }) {
            HelloPickerPopupRow(item: item, isSelected: item.id == selectedItemID, isExpanded: isVisible.wrappedValue)
          }.environment(\.contentShape, AnyInsettableShape(Rectangle()))
        }
      }.frame(width: width)
    }
  }
}

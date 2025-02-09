#if os(iOS)
import SwiftUI

import HelloCore

@MainActor
@Observable
public class HelloPickerGroup {
  
  public static var new: HelloPickerGroup { HelloPickerGroup() }
  
  var widths: [String: CGFloat] = [:]
  
  public func biggestWidth(for pickerID: String? = nil) -> CGFloat? {
    widths.filter { $0.key != pickerID }.values.max()
  }
}

public struct HelloPickerDefaultItemView<Item: HelloPickerItem>: View {
  
  public var option: Item
  
  public var body: some View {
    Text(option.name)
  }
}

enum HelloPickerSizing {
  static var collapsedRowHeight: CGFloat { 40 }
  static var expandedRowHeight: CGFloat { 44 }
}

public struct HelloPicker<Item: HelloPickerItem, ItemContent: View>: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(\.theme) private var theme

  @NonObservedState private var globalFrame: CGRect = .zero
  @NonObservedState private var id: String = .uuid
  
  private var selectedOption: Item
  private var options: [Item]
  private var group: HelloPickerGroup?
  private var onChange: @MainActor (Item) -> Void
  private var content: @MainActor (Item) -> ItemContent
  
  public init(selected: Item,
              options: [Item],
              group: HelloPickerGroup? = nil,
              onChange: @escaping @MainActor (Item) -> Void,
              content: @escaping @MainActor (Item) -> ItemContent) {
    self.selectedOption = selected
    self.options = options
    self.group = group
    self.onChange = onChange
    self.content = content
  }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      windowModel.showPopup {
        HelloPickerPopup(
          position: globalFrame.bottomLeading,
          anchor: .topLeading,
          items: options,
          selectedItemID: selectedOption.id,
          width: globalFrame.width,
          onChange: onChange,
          content: content
        )
      }
    }) {
      HStack(spacing: 0) {
        Image(systemName: "chevron.up.chevron.down")
          .frame(width: 32)
          .foregroundStyle(theme.surfaceSection.foreground.tertiary.style)
        ZStack(alignment: .leading) {
          ForEach(options) { option in
            Text(option.name)
              .lineLimit(1)
              .fixedSize()
              .opacity(selectedOption == option ? 1 : 0)
          }
        }
      }.font(.system(size: 16, weight: .regular))
        .foregroundStyle(theme.surfaceSection.foreground.primary.style)
        .frame(height: HelloPickerSizing.collapsedRowHeight)
        .padding(.trailing, 16)
        .frame(minWidth: group?.biggestWidth(for: id), alignment: .leading)
        .background(theme.surfaceSection.backgroundView(for: .rect(cornerRadius: 10)))
        .frame(height: HelloPickerSizing.expandedRowHeight)
        .readFrame {
          globalFrame = $0
          group?.widths[id] = $0.width
        }
    }.frame(height: 28)
  }
}

public extension HelloPicker where ItemContent == HelloPickerDefaultItemView<Item> {
  init(selected: Item,
       options: [Item],
       group: HelloPickerGroup? = nil,
       onChange: @escaping @MainActor (Item) -> Void) {
    self.init(selected: selected,
              options: options,
              group: group,
              onChange: onChange,
              content: HelloPickerDefaultItemView.init)
  }
}
#endif

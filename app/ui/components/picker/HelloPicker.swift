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

public struct HelloPicker<Item: HelloPickerItem>: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  
  @NonObservedState private var globalFrame: CGRect = .zero
  @NonObservedState private var id: String = .uuid
  
  private var selectedOption: Item
  private var options: [Item]
  private var group: HelloPickerGroup?
  private var onChange: @MainActor (Item) -> Void
  
  public init(selected: Item,
              options: [Item],
              group: HelloPickerGroup? = nil,
              onChange: @escaping @MainActor (Item) -> Void) {
    self.selectedOption = selected
    self.options = options
    self.group = group
    self.onChange = onChange
  }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      windowModel.showPopup {
        HelloPickerPopup(
          position: globalFrame.bottomLeading,
          anchor: .topLeading,
          items: options.map { option in
            HelloPickerPopupItem(id: option.id, name: option.name, action: {
              onChange(option)
            })
          },
          selectedItemID: selectedOption.id,
          width: globalFrame.width)
        //                  anchor: .top,
        //                  items: menuItems)
      }
    }) {
      HStack(spacing: 0) {
        Image(systemName: "chevron.up.chevron.down")
          .frame(width: 32)
          .foregroundStyle(theme.surfaceSection.foreground.tertiary.style)
        ZStack(alignment: .leading) {
          ForEach(options) { option in
            Text(option.name)
              .fixedSize()
              .opacity(selectedOption == option ? 1 : 0)
          }
        }
      }.font(.system(size: 16, weight: .regular))
        .foregroundStyle(theme.surfaceSection.foreground.primary.style)
        .frame(height: HelloPickerPopup.collapsedRowHeight)
        .padding(.trailing, 16)
        .frame(minWidth: group?.biggestWidth(for: id), alignment: .leading)
        .background(theme.surfaceSection.backgroundView(for: .rect(cornerRadius: 10)))
        .frame(height: HelloPickerPopup.expandedRowHeight)
        .readFrame {
          globalFrame = $0
          group?.widths[id] = $0.width
        }
    }.frame(height: 28)
  }
}
#endif

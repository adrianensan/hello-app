import SwiftUI

import HelloCore

public struct HelloPicker<Item: HelloPickerItem>: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  
  @NonObservedState private var globalFrame: CGRect = .zero
  
  private var selectedOption: Item
  private var options: [Item]
  private var onChange: @MainActor (Item) -> Void
  
  public init(selected: Item, options: [Item], onChange: @escaping @MainActor (Item) -> Void) {
    self.selectedOption = selected
    self.options = options
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
        ZStack(alignment: .leading) {
          ForEach(options) { option in
            Text(option.name)
              .fixedSize()
              .opacity(selectedOption == option ? 1 : 0)
          }
        }
      }.font(.system(size: 16, weight: .regular))
        .foregroundStyle(theme.surfaceSection.foreground.primary.style)
        .frame(height: 36)
        .padding(.trailing, 16)
        .background(theme.surfaceSection.backgroundView(for: .rect(cornerRadius: 10)))
        .frame(height: 44)
        .readFrame(to: $globalFrame)
    }.frame(height: 28)
  }
}

import SwiftUI

import HelloCore

public struct HelloToggle: View {
  
  @Environment(\.theme) var theme
  
  var isSelected: Bool
  var action: () -> Void
  
  public init(isSelected: Bool, action: @escaping () -> Void) {
    self.isSelected = isSelected
    self.action = action
  }
  
  public var body: some View {
    HelloButton(haptics: .action, action: { action() }) {
      Capsule(style: .continuous)
        .fill(.white)
        .frame(width: 28, height: 28)
        .padding(2)
        .frame(width: 52, height: 32, alignment: isSelected ? .trailing : .leading)
        .background {
          Capsule(style: .continuous)
            .fill(theme.accentStyle)
            .opacity(isSelected ? 1 : 0)
        }.background(Capsule(style: .continuous).fill(Color.black.opacity(0.1)))
        .animation(.dampSpring, value: isSelected)
    }
  }
}

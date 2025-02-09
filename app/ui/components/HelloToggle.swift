import SwiftUI

import HelloCore

public struct HelloToggle: View {
  
  @Environment(\.theme) private var theme
  
  private var isSelected: Bool
  private var action: @MainActor () async throws -> Void
  
  public init(isSelected: Bool, action: @escaping @MainActor () async throws -> Void) {
    self.isSelected = isSelected
    self.action = action
  }
  
  public init(_ property: Persistent<some PersistenceProperty<Bool>>) {
    self.isSelected = property.wrappedValue
    self.action = { property.wrappedValue.toggle() }
  }
  
  public init(isSelected: Binding<Bool>) {
    self.isSelected = isSelected.wrappedValue
    self.action = { isSelected.wrappedValue.toggle() }
  }
  
  public var body: some View {
    HelloButton(action: { try await action() }) {
      Capsule(style: .continuous)
        .fill(.white.opacity(theme.theme.isDim ? 0.5 : 1))
        .frame(width: 28, height: 28)
        .padding(2)
        .frame(width: 52, height: 32, alignment: isSelected ? .trailing : .leading)
        .background {
          Capsule(style: .continuous)
            .fill(theme.accentStyle)
            .opacity(isSelected ? 1 : 0)
            .frame(width: isSelected ? 52 : 32, height: 32)
            .frame(width: 52, height: 32, alignment: .leading)
        }.background(Capsule(style: .continuous)
          .fill(Color.black.opacity(0.1))
          .overlay(Capsule(style: .continuous)
            .stroke(theme.foreground.primary.color.opacity(0.1), lineWidth: 1)))
        .animation(.dampSpring, value: isSelected)
    }
  }
}

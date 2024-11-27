import SwiftUI

import HelloCore

fileprivate struct KeyboardButtonStyle: ButtonStyle {
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .brightness(configuration.isPressed ? -0.1 : 0)
  }
}

fileprivate extension ButtonStyle where Self == KeyboardButtonStyle {
  static var keyboard: KeyboardButtonStyle { KeyboardButtonStyle() }
}

public struct HelloKeyboard: View {
  
  enum HelloKeyboardAction: Sendable {
    case typeCharacter(Character)
    case backspace
  }
  
  @Environment(\.theme) private var theme
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.safeArea) private var safeAreaInsets
  
  @Binding var string: String
  
  var rows: [String] = [
    "1234567890",
    "qwertyuiop",
    "asdfghjkl"
  ]
  
  public init(string: Binding<String>) {
    self._string = string
  }
  
  @State private var keySize: CGSize = .zero
  
  var keyPadding: CGFloat {
    keySize.width / 12
  }
  
  func action(_ action: HelloKeyboardAction) {
    switch action {
    case .typeCharacter(let character):
      guard string.count < 12 else { return }
      string += character.uppercased()
    case .backspace:
      if !string.isEmpty {
        string.removeLast()
      }
    }
  }
  
  func updateSize() {
    let keyWidth = min(72, (windowFrame.size.width - 8) / 10)
    let keyHeight = min(72, max(44, windowFrame.size.width / 9))
    let keySize = CGSize(width: keyWidth, height: keyHeight)
    if self.keySize != keySize {
      self.keySize = keySize
    }
  }
  
  public var body: some View {
    VStack(spacing: 2) {
      ForEach(rows, id: \.self) { letters in
        HStack(spacing: 0) {
          ForEach([Character](letters), id: \.self) { character in
            HelloButton(clickStyle: .highlight, action: { action(.typeCharacter(character)) }) {
              Text(character.uppercased())
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .frame(width: keySize.width - keyPadding, height: keySize.height - keyPadding)
                .background(theme.surface.backgroundView(for: .rect(cornerRadius: 8)))
                .frame(width: keySize.width, height: keySize.height)
            }.keyboardShortcut(.init(.init(character.lowercased())), modifiers: [])
              .keyboardShortcut(.init(.init(character.uppercased())), modifiers: [])
          }
        }
      }
      HStack(spacing: 0) {
        Color.clear.frame(width: keySize.width, height: keySize.height)
        ForEach([Character]("zxcvbnm"), id: \.self) { character in
          HelloButton(clickStyle: .highlight, action: { action(.typeCharacter(character)) }) {
            Text(character.uppercased())
              .font(.system(size: 16, weight: .semibold, design: .rounded))
              .frame(width: keySize.width - keyPadding, height: keySize.height - keyPadding)
              .background(theme.surface.backgroundView(for: .rect(cornerRadius: 8)))
              .frame(width: keySize.width, height: keySize.height)
          }.keyboardShortcut(.init(.init(character.lowercased())), modifiers: [])
            .keyboardShortcut(.init(.init(character.uppercased())), modifiers: [])
        }
        HelloButton(clickStyle: .highlight, action: { action(.backspace) }) {
          Image(systemName: "delete.left")
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .frame(width: 1.5 * keySize.width - keyPadding, height: keySize.height - keyPadding)
            .background(theme.surface.backgroundView(for: .rect(cornerRadius: 8)))
            .frame(width: 2 * keySize.width, height: keySize.height)
        }.keyboardShortcut(.init("\u{08}"), modifiers: [])
          .disabled(string.isEmpty)
      }
    }.foregroundStyle(theme.surface.foreground.primary.style)
      .clickable()
      .padding(.top, 4)
      .padding(.bottom, safeAreaInsets.bottom + 8)
      .frame(maxWidth: .infinity)
      .background(theme.backgroundView(isBaseLayer: true))
      .onChange(of: windowFrame.size, initial: true) { updateSize() }
  }
}

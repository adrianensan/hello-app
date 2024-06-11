#if os(macOS)
import SwiftUI

import HelloApp

public struct HelloTextField<FocusValue: Hashable>: View {
  
  @Environment(\.theme) private var theme
  
  private var placeholder: String
  private var isSecure: Bool
  private var focusValue: FocusValue
  @Binding private var text: String
  @FocusState.Binding private var currentFocus: FocusValue?
  private var onSubmit: @Sendable () -> Void
  
  @State private var isHovered: Bool = false
  
  public init(placeholder: String,
              isSecure: Bool = false,
              focusValue: FocusValue,
              text: Binding<String>,
              currentFocus: FocusState<FocusValue?>.Binding,
              isHovered: Bool,
              onSubmit: @escaping @Sendable () -> Void) {
    self.placeholder = placeholder
    self.isSecure = isSecure
    self.focusValue = focusValue
    _text = text
    _currentFocus = currentFocus
    self.isHovered = isHovered
    self.onSubmit = onSubmit
  }
  
  private var isFocused: Bool { currentFocus == focusValue }
  
  public var body: some View {
    HelloNSTextField(text: $text,
                     placeholder: placeholder,
                     fontSize: 20,
                     isEditable: true,
                     isSecure: isSecure,
                     currentFocus: $currentFocus,
                     focusValue: focusValue, 
                     onSubmit: onSubmit)
    .padding(.horizontal, 10)
    .frame(height: 44)
    .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
      .stroke(isFocused ? theme.accent.color : theme.foreground.primary.color.opacity(0.25), lineWidth: 1))
    .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
      .fill(theme.foreground.primary.color.opacity(isHovered && !isFocused ? 0.05 : 0)))
    .background(theme.surface.backgroundView(for: RoundedRectangle(cornerRadius: 16, style: .continuous)))
    .onTapGesture { currentFocus = focusValue }
    .focused($currentFocus, equals: focusValue)
    .onHover { isHovered = $0 }
  }
}
#endif

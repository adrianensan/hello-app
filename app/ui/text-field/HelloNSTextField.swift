#if os(macOS)
import SwiftUI

import HelloCore

class HelloFocusNSTextField: NSTextField, NSTextFieldDelegate {
  var onFocus: (() -> Void)?
  
  override func becomeFirstResponder() -> Bool {
    onFocus?()
    return super.becomeFirstResponder()
  }
}

class HelloFocusNSSecureTextField: NSSecureTextField, NSTextFieldDelegate {
  var onFocus: (() -> Void)?
  
  override func becomeFirstResponder() -> Bool {
    onFocus?()
    return super.becomeFirstResponder()
  }
}


@MainActor
public struct HelloNSTextField<FocusValue: Hashable>: NSViewRepresentable {
  
  public class Coordinator: NSObject, NSTextFieldDelegate {
    
    var textField: HelloNSTextField
    var isFocused: Bool = false
    var isMultiLine: Bool
    var onSubmit: @MainActor @Sendable () -> Void
    
    init(textField: HelloNSTextField, isMultiLine: Bool = false, onSubmit: @MainActor @Sendable @escaping () -> Void) {
      self.textField = textField
      self.isMultiLine = isMultiLine
      self.onSubmit = onSubmit
    }
    
    public func controlTextDidBeginEditing(_ obj: Notification) {
      isFocused = true
      textField.onFocus()
    }
    
    public func controlTextDidEndEditing(_ obj: Notification) {
      isFocused = false
      if textField.currentFocus == textField.focusValue {
        textField.currentFocus = nil
      }
    }
    
    public func controlTextDidChange(_ obj: Notification) {
      guard let text = (obj.object as? NSTextField)?.stringValue else { return }
      if textField.text != text {
        textField.text = text
      }
    }
    
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
      switch commandSelector {
      case #selector(NSTextView.insertNewline(_:)):
        if isMultiLine {
          textView.insertNewlineIgnoringFieldEditor(self)
        } else {
          onSubmit()
        }
        return true
      default: return false
      }
    }
  }
  
  @Binding var text: String
  @FocusState.Binding var currentFocus: FocusValue?
  
  var placeholder: String
  var fontSize: CGFloat
  var isEditable: Bool
  var isSecure: Bool
  var maxNumberOfLines: Int
  var focusValue: FocusValue
  var onSubmit: @MainActor @Sendable () -> Void
  
  public init(text: Binding<String>,
              placeholder: String,
              fontSize: CGFloat = 15,
              isEditable: Bool,
              isSecure: Bool = false,
              maxNumberOfLines: Int = 1,
              currentFocus: FocusState<FocusValue?>.Binding,
              focusValue: FocusValue,
              onSubmit: @MainActor @escaping @Sendable () -> Void) {
    _text = text
    self.placeholder = placeholder
    self.fontSize = fontSize
    self.isEditable = isEditable
    self.isSecure = isSecure
    self.maxNumberOfLines = maxNumberOfLines
    _currentFocus = currentFocus
    self.focusValue = focusValue
    self.onSubmit = onSubmit
  }
  
  var shouldBeFocused: Bool { currentFocus == focusValue }
  
  func onFocus() {
    Task {
      if currentFocus != focusValue {
        currentFocus = focusValue
      }
    }
  }
  
  public func makeNSView(context: Context) -> NSTextField {
    let textField: NSTextField
    if isSecure {
      textField = HelloFocusNSSecureTextField() +& {
        $0.onFocus = { onFocus() }
        $0.delegate = $0
      }
    } else {
      textField = HelloFocusNSTextField() +& {
        $0.onFocus = { onFocus() }
        $0.delegate = $0
      }
    }
    textField.placeholderString = placeholder
    if maxNumberOfLines > 1 {
      textField.heightAnchor.constraint(equalToConstant: CGFloat(maxNumberOfLines) * 20).isActive = true
    }
    textField.font = .systemFont(ofSize: fontSize, weight: .regular)
    textField.isBezeled = false
    textField.isBordered = false
    textField.maximumNumberOfLines = maxNumberOfLines
    textField.lineBreakMode = maxNumberOfLines > 1 ? .byWordWrapping : .byTruncatingTail
    textField.usesSingleLineMode = maxNumberOfLines < 2
    textField.focusRingType = .none
    textField.backgroundColor = .clear
    textField.delegate = context.coordinator
    return textField
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(textField: self, isMultiLine: maxNumberOfLines > 1, onSubmit: onSubmit)
  }
  
  public func updateNSView(_ textField: NSTextField, context: Context) {
    //    textField.textColor = theme.textPrimary.nativeColor
    textField.isEditable = isEditable
    if textField.stringValue != text {
      textField.stringValue = text
    }
    if shouldBeFocused && !context.coordinator.isFocused {
      textField.becomeFirstResponder()
      context.coordinator.isFocused = true
    } else if !shouldBeFocused && context.coordinator.isFocused {
      textField.endEditing(.init())
      context.coordinator.isFocused = false
    }
  }
}
#endif

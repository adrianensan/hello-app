import SwiftUI

#if os(iOS)
private struct KeyboardFrameEnvironmentKey: EnvironmentKey {
  static let defaultValue = CGRect()
}

public extension EnvironmentValues {
  var keyboardFrame: CGRect {
    get { self[KeyboardFrameEnvironmentKey.self] }
    set { self[KeyboardFrameEnvironmentKey.self] = newValue }
  }
}

struct KeyboardFrameObservationViewModifier: ViewModifier {
  
  @State private var keyboardFrame: CGRect = .zero
  
  func updateKeyboardFrame(to newKeyboardFrame: CGRect, animationDuration: Double?) {
    guard keyboardFrame != newKeyboardFrame else { return }
    if let keyboardFrameAnimationDuration = animationDuration {
      withAnimation(.easeOut(duration: keyboardFrameAnimationDuration)) {
        keyboardFrame = newKeyboardFrame
      }
    } else {
      keyboardFrame = newKeyboardFrame
    }
  }
  
  func body(content: Content) -> some View {
    content
      .environment(\.keyboardFrame, keyboardFrame)
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { notification in
        let newKeyboardFrame: CGRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        let keyboardFrameAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        updateKeyboardFrame(to: newKeyboardFrame, animationDuration: keyboardFrameAnimationDuration)
      }.onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)) { notification in
        let keyboardFrameAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        updateKeyboardFrame(to: .zero, animationDuration: keyboardFrameAnimationDuration)
      }
  }
}

public extension View {
  func observeKeyboardFrame() -> some View {
    modifier(KeyboardFrameObservationViewModifier())
  }
}
#else
public extension View {
  func observeKeyboardFrame() -> some View {
    self
  }
}
#endif

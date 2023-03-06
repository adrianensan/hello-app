import SwiftUI

import HelloCore

public extension View {
  func delaysTouches(for duration: TimeInterval? = nil,
                     onTouch touchAction: @escaping (Bool) -> Void,
                     onTap action: @escaping () -> Void) -> some View {
    modifier(DelaysTouches(duration: duration, touchAction: touchAction, action: action))
  }
}

fileprivate struct DelaysTouches: ViewModifier {
  @State private var disabled = false
  @State private var touchDownDate: Date? = nil
  
  var duration: TimeInterval?
  var touchAction: (Bool) -> Void
  var action: () -> Void
  
  func body(content: Content) -> some View {
    Button(action: action) {
      content
    }
    .buttonStyle(DelaysTouchesButtonStyle(disabled: $disabled,
                                          duration: duration,
                                          touchDownDate: $touchDownDate,
                                          isPressedAction: touchAction))
    .disabled(disabled)
  }
}

@MainActor
fileprivate struct DelaysTouchesButtonStyle: ButtonStyle {
  @Binding var disabled: Bool
  var duration: TimeInterval?
  @Binding var touchDownDate: Date?
  var isPressedAction: (Bool) -> Void
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .onChange(of: configuration.isPressed, perform: handleIsPressed)
  }
  
  private func handleIsPressed(isPressed: Bool) {
    isPressedAction(isPressed)
    if isPressed {
      guard let duration = duration else { return }
      let date = Date()
      touchDownDate = date
      
      Task {
        try await Task.sleep(seconds: max(duration, 0))
        if date == touchDownDate {
          disabled = true
          
          Task {
            disabled = false
          }
        }
      }
    } else {
      touchDownDate = nil
      disabled = false
    }
  }
}

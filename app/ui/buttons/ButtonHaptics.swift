import SwiftUI

public enum ButtonHaptics {
  
#if os(iOS)
  private static let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
#endif
  
  public static func buttonFeedback() {
#if os(iOS)
    selectionFeedbackGenerator.selectionChanged()
#elseif os(watchOS)
    WKInterfaceDevice.current().play(.click)
#endif
  }
}

public extension View {
  func buttonHaptics(isPressed: Bool) -> some View {
    onChange(of: isPressed, perform: {
      if $0 {
        ButtonHaptics.buttonFeedback()
      }
    })
  }
}

import SwiftUI
import Observation

import HelloCore

@MainActor
public struct ObserveSmallWindowSizeViewModifier: ViewModifier {
  
  @Environment(\.windowFrame) private var windowFrame
  
  @Binding var isSmallWindow: Bool
  
  var threshold: CGFloat
  
  public func body(content: Content) -> some View {
    content
      .onChange(of: windowFrame, initial: true) {
        let isSmallWindow = windowFrame.height < threshold
        if self.isSmallWindow != isSmallWindow {
          self.isSmallWindow = isSmallWindow
        }
      }
  }
}

@MainActor
public extension View {
  func observeSmallWindowSize(threshold: CGFloat = 600, isSmallWindow: Binding<Bool>) -> some View {
    modifier(ObserveSmallWindowSizeViewModifier(isSmallWindow: isSmallWindow, threshold: threshold))
  }
}

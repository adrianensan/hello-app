import SwiftUI
import Observation

import HelloCore

#if os(iOS)
@MainActor
public struct SafeAreaInsetsViewModifier: ViewModifier {
  
  @Environment(\.safeArea) private var safeAreaInsets
  @Environment(\.keyboardFrame) private var keyboardFrame
  
  public func body(content: Content) -> some View {
    content
      .safeAreaInset(edge: .top, spacing: 0) {
        Color.clear.frame(height: safeAreaInsets.top)
      }.safeAreaInset(edge: .bottom, spacing: 0) {
        Color.clear.frame(height: max(safeAreaInsets.bottom, keyboardFrame.size.height))
      }.safeAreaInset(edge: .leading, spacing: 0) {
        Color.clear.frame(width: safeAreaInsets.leading)
      }.safeAreaInset(edge: .trailing, spacing: 0) {
        Color.clear.frame(width: safeAreaInsets.trailing)
      }
  }
}

@MainActor
public extension View {
  func insetBySafeArea() -> some View {
    modifier(SafeAreaInsetsViewModifier())
  }
}
#else
@MainActor
public struct SafeAreaInsetsViewModifier: ViewModifier {
  
  @Environment(\.safeArea) private var safeAreaInsets
  
  public func body(content: Content) -> some View {
    content
      .safeAreaInset(edge: .top, spacing: 0) {
        Color.clear.frame(height: safeAreaInsets.top)
      }.safeAreaInset(edge: .bottom, spacing: 0) {
        Color.clear.frame(height: safeAreaInsets.bottom)
      }.safeAreaInset(edge: .leading, spacing: 0) {
        Color.clear.frame(width: safeAreaInsets.leading)
      }.safeAreaInset(edge: .trailing, spacing: 0) {
        Color.clear.frame(width: safeAreaInsets.trailing)
      }
  }
}

@MainActor
public extension View {
  func insetBySafeArea() -> some View {
    modifier(SafeAreaInsetsViewModifier())
  }
}
#endif

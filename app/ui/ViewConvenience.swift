import SwiftUI

@MainActor
public extension View {
  @ViewBuilder
  func `if`(_ condition: Bool, viewModifier: @MainActor (Self) -> some View) -> some View {
    if condition {
      viewModifier(self)
    } else {
      self
    }
  }
  
  @ViewBuilder
  func ifLet<T>(_ optional: T?, viewModifier: @MainActor (Self, T) -> some View) -> some View {
    if let optional {
      viewModifier(self, optional)
    } else {
      self
    }
  }
  
  @ViewBuilder
  func when(_ condition: Bool, initial: Bool = false, action: @MainActor @escaping () -> Void) -> some View {
    onChange(of: condition, initial: initial) {
      guard condition else { return }
      action()
    }
  }
  
  @ViewBuilder
  func when(_ condition: Bool, initial: Bool = false, action: @MainActor @escaping () async throws -> Void) -> some View {
    onChange(of: condition, initial: initial) {
      guard condition else { return }
      Task { try await action() }
    }
  }
  
  func debug(modifier: (Self) -> some View) -> some View {
    #if DEBUG
    modifier(self)
    #else
    self
    #endif
  }
  
  func simulator(modifier: (Self) -> some View) -> some View {
    #if targetEnvironment(simulator)
    modifier(self)
    #else
    self
    #endif
  }
}



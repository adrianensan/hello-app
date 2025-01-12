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
  func ifLet<T: Equatable>(_ optional: T?, viewModifier: @MainActor @escaping (T) -> Void) -> some View {
    onChange(of: optional, initial: true) {
      guard let optional else { return }
      viewModifier(optional)
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
  
  @ViewBuilder
  func onChange(of value: some Equatable, initial: Bool = false, action: @MainActor @escaping () async throws -> Void) -> some View {
    onChange(of: value, initial: initial) {
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



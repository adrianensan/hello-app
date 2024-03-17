import SwiftUI

@MainActor
public extension View {
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



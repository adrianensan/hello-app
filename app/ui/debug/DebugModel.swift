import Foundation

import HelloCore

@Observable
@MainActor
public class DebugModel {
  
  public static let main = DebugModel()
  
  private var showBordersProperty = Persistence.model(for: .showDebugBorders)
  public var showBorders: Bool {
    get { showBordersProperty.value }
    set { showBordersProperty.value = newValue }
  }
  
  private var disableMaskingProperty = Persistence.model(for: .disableMasking)
  public var disableMasking: Bool {
    get { disableMaskingProperty.value }
    set { disableMaskingProperty.value = newValue }
  }
  
  private init() {}
}

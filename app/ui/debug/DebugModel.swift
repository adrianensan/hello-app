import Foundation

import HelloCore

@Observable
@MainActor
public class DebugModel {
  
  public static let main = DebugModel()
  
  public var showBorders: Bool = Persistence.unsafeValue(.showDebugBorders)
  
  private init() {}
}

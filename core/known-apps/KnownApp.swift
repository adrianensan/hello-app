import Foundation

public struct KnownApp: Identifiable, Codable, Sendable {
  public var bundleID: String
  public var name: String
  public var url: String
  
  public var id: String { bundleID }
}

import Foundation

@propertyWrapper
public struct HelloEnvironmentObject<EnvironmentObject: HelloEnvironmentObjectKey> {
  
  private let object: EnvironmentObject.Object
  
  public init(_ environmentObject: EnvironmentObject) {
    object = HelloEnvironment.object(for: environmentObject)
  }
  
  public var wrappedValue: EnvironmentObject.Object { object }
}

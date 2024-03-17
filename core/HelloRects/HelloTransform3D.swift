import Foundation

public typealias FloatTransform3D = HelloTransform3D<Float>

public struct HelloTransform3D<NumberType: HelloNumeric>: Hashable, Codable, Sendable {
  
  public static var identity: HelloTransform3D<NumberType> {
    HelloTransform3D<NumberType>(rotation: .zero, translation: .zero, scale: .one)
  }
  
  public var rotation: HelloRotation3D<NumberType>
  public var translation: HelloPoint3D<NumberType>
  public var scale: HelloPoint3D<NumberType>
  
  public init(rotation: HelloRotation3D<NumberType> = .zero,
              translation: HelloPoint3D<NumberType> = .zero,
              scale: HelloPoint3D<NumberType> = .one) {
    self.rotation = rotation
    self.translation = translation
    self.scale = scale
  }
}

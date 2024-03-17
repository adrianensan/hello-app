import Foundation

public typealias FloatRotation3D = HelloRotation3D<Float>

public struct HelloRotation3D<NumberType: HelloNumeric>: Hashable, Codable, Sendable {
  
  public static var zero: HelloRotation3D<NumberType> { HelloRotation3D<NumberType>(angle: 0, axis: .zero) }
  
  public var angle: NumberType
  public var axis: HelloPoint3D<NumberType>
  
  public init(angle: NumberType, axis: HelloPoint3D<NumberType>) {
    self.angle = angle
    self.axis = axis
  }
}

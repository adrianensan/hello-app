import Foundation

extension SIMD2<Float>: HelloPointConformable {
  public init(x: some BinaryFloatingPoint, y: some BinaryFloatingPoint) {
    self.init(x: Float(x), y: Float(y))
  }
  
  public init(x: some BinaryInteger, y: some BinaryInteger) {
    self.init(x: Float(x), y: Float(y))
  }
}

extension CGSize: HelloSizeConformable {
  public init(width: some BinaryFloatingPoint, height: some BinaryFloatingPoint) {
    self.init(width: CGFloat(width), height: CGFloat(height))
  }
  
  public init(width: some BinaryInteger, height: some BinaryInteger) {
    self.init(width: CGFloat(width), height: CGFloat(height))
  }
}

extension CGPoint: HelloPointConformable {
  public init(x: some BinaryFloatingPoint, y: some BinaryFloatingPoint) {
    self.init(x: CGFloat(x), y: CGFloat(y))
  }
  
  public init(x: some BinaryInteger, y: some BinaryInteger) {
    self.init(x: CGFloat(x), y: CGFloat(y))
  }
}

extension CGRect: HelloRectConformable {
  public typealias NumberType = CGFloat
}

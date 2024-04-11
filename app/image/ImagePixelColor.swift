import Foundation

import HelloCore

public extension NativeImage {
  func pixelColor(at point: CGPoint) -> HelloColor? {
    guard let pixelData = cgImage?.dataProvider?.data else { return nil }
    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
    
    let pixelInfo: Int = ((Int(size.width) * Int(point.y)) + Int(point.x)) * 4
    
    let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
    let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
    let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
    let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
    return HelloColor(r: r, g: g, b: b, a: a, colorSpace: .sRGB)
  }
  
  var borderColor: HelloColor? {
    guard size.width > 2 && size.height > 2 else { return nil }
    guard let color = pixelColor(at: CGPoint(x: 0, y: 0.5 * size.height)), color.a == 1 else { return nil }
    guard
//      pixelColor(at: CGPoint(x: 0, y: 0.25 * size.height)) == color,
      pixelColor(at: CGPoint(x: 0, y: 0.25 * size.height)) == color,
      pixelColor(at: CGPoint(x: 0, y: 0.5 * size.height)) == color,
      pixelColor(at: CGPoint(x: 0, y: 0.25 * size.height)) == color,
//      pixelColor(at: CGPoint(x: 0, y: 0.75 * size.height)) == color,
//      pixelColor(at: CGPoint(x: size.width, y: 0.25 * size.height)) == color,
//      pixelColor(at: CGPoint(x: size.width, y: 0.5 * size.height)) == color,
//      pixelColor(at: CGPoint(x: size.width, y: 0.75 * size.height)) == color,
//      pixelColor(at: CGPoint(x: 0.25 * size.width, y: 0)) == color,
      pixelColor(at: CGPoint(x: 0.25 * size.width, y: 0)) == color,
      pixelColor(at: CGPoint(x: 0.5 * size.width, y: 0)) == color,
      pixelColor(at: CGPoint(x: 0.75 * size.width, y: 0)) == color
//      pixelColor(at: CGPoint(x: 0.75 * size.width, y: 0)) == color,
//      pixelColor(at: CGPoint(x: 0.25 * size.width, y: size.height)) == color,
//      pixelColor(at: CGPoint(x: 0.5 * size.width, y: size.height)) == color
//      pixelColor(at: CGPoint(x: 0.75 * size.width, y: size.height)) == color
    else { return nil }
//    for x in 0..<Int(size.width) {
//      guard 
//        pixelColor(at: CGPoint(x: x, y: 0)) == color,
//        pixelColor(at: CGPoint(x: x, y: Int(size.height))) == color
//      else { return nil }
//    }
//    
//    for y in 0..<Int(size.height) {
//      guard 
//        pixelColor(at: CGPoint(x: 0, y: y)) == color,
//        pixelColor(at: CGPoint(x: Int(size.width), y: y)) == color else { return nil }
//    }
    
    return color
  }
  
  var hasFlatEdge: Bool {
    abs(size.width - size.height) < 2 && size.width * scale > 8 &&
    (stride(from: 0.2, to: 0.8, by: 0.04).allSatisfy { pixelColor(at: CGPoint(x: CGFloat($0) * size.width, y: 0))?.isOpaque == true } &&
    stride(from: 0.2, to: 0.8, by: 0.04).allSatisfy { pixelColor(at: CGPoint(x: 0, y: CGFloat($0) * size.height))?.isOpaque == true })
  }
}

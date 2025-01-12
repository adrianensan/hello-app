import Foundation
import CoreGraphics

import HelloCore

public class ImagePixelReader {
  static func reader(for image: NativeImage) -> ImagePixelReader? {
    guard let cgImage = image.cgImage else { return nil }
    return ImagePixelReader(cgImage: cgImage)
  }
  
  private var data: [UInt8]
  private var colorSpace: CGColorSpaceModel
  private var size: IntSize
  private let bytesPerRow: Int
  private let bytesPerPixel: Int
  
  init?(cgImage: CGImage) {
    guard let cfPixelData = cgImage.dataProvider?.data else { return nil }
    guard let colorSpaceModel = cgImage.colorSpace?.model,
          [.rgb, .monochrome].contains(colorSpaceModel)
    else { return nil }
    let dataPointer = CFDataGetBytePtr(cfPixelData)
    data = Array(UnsafeBufferPointer(start: dataPointer, count: cgImage.width * cgImage.height * cgImage.bitsPerPixel / 8))
    self.colorSpace = colorSpaceModel
    self.size = IntSize(width: cgImage.width, height: cgImage.height)
    self.bytesPerRow = cgImage.bytesPerRow
    self.bytesPerPixel = cgImage.bitsPerPixel / 8
  }
  
  public func pixelColor(percentage point: CGPoint) -> HelloColor? {
    pixelColor(at: IntPoint(x: Int(point.x * Double(size.width)),
                            y: Int(point.y * Double(size.height))))
  }
  
  public func pixelColor(at point: IntPoint) -> HelloColor? {
    guard point.x < size.width && point.y < size.height else { return nil }
    let pixelIndex: Int = ((size.width * point.y) + point.x) * bytesPerPixel
    
    switch colorSpace {
    case .rgb:
      let r = CGFloat(data[pixelIndex]) / CGFloat(255.0)
      let g = CGFloat(data[pixelIndex + 1]) / CGFloat(255.0)
      let b = CGFloat(data[pixelIndex + 2]) / CGFloat(255.0)
      let a = CGFloat(data[pixelIndex + 3]) / CGFloat(255.0)
      return HelloColor(r: r, g: g, b: b, a: a, colorSpace: .sRGB)
    case .monochrome:
      let w = CGFloat(data[pixelIndex]) / CGFloat(255.0)
      let a = CGFloat(data[pixelIndex + 1]) / CGFloat(255.0)
      return HelloColor(r: w, g: w, b: w, a: a, colorSpace: .sRGB)
    default: return nil
    }
  }
}

public extension NativeImage {
//  func pixelColor(at point: CGPoint) -> HelloColor? {
//    guard let cgImage else { return nil }
//    guard let pixelData = cgImage.dataProvider?.data else { return nil }
//    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
//    guard let colorSpaceModel = cgImage.colorSpace?.model
//    else { return nil }
//    
//    switch colorSpaceModel {
//    case .rgb:
//      let bytesPerRow = cgImage.bytesPerRow
//      let bytesPerPixel = cgImage.bitsPerPixel / 8
//      
//      let pixelInfo: Int = ((Int(size.width) * Int(point.y)) + Int(point.x)) * bytesPerPixel
//      
//      let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
//      let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
//      let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
//      let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
//      return HelloColor(r: r, g: g, b: b, a: a, colorSpace: .sRGB)
//    case .monochrome:
//      let bytesPerRow = cgImage.bytesPerRow
//      let bytesPerPixel = cgImage.bitsPerPixel / 8
//      
//      let pixelInfo: Int = ((Int(size.width) * Int(point.y)) + Int(point.x)) * bytesPerPixel
//      
//      let w = CGFloat(data[pixelInfo]) / CGFloat(255.0)
//      let a = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
//      return HelloColor(r: w, g: w, b: w, a: a, colorSpace: .sRGB)
//    default: return nil
//    }
//  }
  
//  var borderColor: HelloColor? {
//    guard size.width > 2 && size.height > 2 else { return nil }
//    guard let color = pixelColor(at: CGPoint(x: 0, y: 0.5 * size.height)), color.a == 1 else { return nil }
//    guard
////      pixelColor(at: CGPoint(x: 0, y: 0.25 * size.height)) == color,
//      pixelColor(at: CGPoint(x: 0, y: 0.25 * size.height)) == color,
//      pixelColor(at: CGPoint(x: 0, y: 0.5 * size.height)) == color,
//      pixelColor(at: CGPoint(x: 0, y: 0.25 * size.height)) == color,
////      pixelColor(at: CGPoint(x: 0, y: 0.75 * size.height)) == color,
////      pixelColor(at: CGPoint(x: size.width, y: 0.25 * size.height)) == color,
////      pixelColor(at: CGPoint(x: size.width, y: 0.5 * size.height)) == color,
////      pixelColor(at: CGPoint(x: size.width, y: 0.75 * size.height)) == color,
////      pixelColor(at: CGPoint(x: 0.25 * size.width, y: 0)) == color,
//      pixelColor(at: CGPoint(x: 0.25 * size.width, y: 0)) == color,
//      pixelColor(at: CGPoint(x: 0.5 * size.width, y: 0)) == color,
//      pixelColor(at: CGPoint(x: 0.75 * size.width, y: 0)) == color
////      pixelColor(at: CGPoint(x: 0.75 * size.width, y: 0)) == color,
////      pixelColor(at: CGPoint(x: 0.25 * size.width, y: size.height)) == color,
////      pixelColor(at: CGPoint(x: 0.5 * size.width, y: size.height)) == color
////      pixelColor(at: CGPoint(x: 0.75 * size.width, y: size.height)) == color
//    else { return nil }
////    for x in 0..<Int(size.width) {
////      guard 
////        pixelColor(at: CGPoint(x: x, y: 0)) == color,
////        pixelColor(at: CGPoint(x: x, y: Int(size.height))) == color
////      else { return nil }
////    }
////    
////    for y in 0..<Int(size.height) {
////      guard 
////        pixelColor(at: CGPoint(x: 0, y: y)) == color,
////        pixelColor(at: CGPoint(x: Int(size.width), y: y)) == color else { return nil }
////    }
//    
//    return color
//  }
  
  var hasFlatEdge: Bool {
    guard let pixelReader = ImagePixelReader.reader(for: self) else { return false }
    return abs(size.width - size.height) < 2 && size.width > 8 &&
    (stride(from: 0.2, to: 0.8, by: 0.04).allSatisfy { pixelReader.pixelColor(percentage: CGPoint(x: $0, y: 0))?.isOpaque == true } &&
     stride(from: 0.2, to: 0.8, by: 0.04).allSatisfy { pixelReader.pixelColor(percentage: CGPoint(x: 0, y: $0))?.isOpaque == true })
  }
  
  var needsTint: Bool {
    var color: HelloColor?
    guard let pixelReader = ImagePixelReader.reader(for: self) else { return false }
    var effectiveWhiteCount: Float = 0
    var effectiveBlackCount: Float = 0
    var effectiveTransparentCount: Float = 0
    var colorCount: Float = 0
    for x in stride(from: 0.0, to: 1.0, by: 0.1) {
      for y in stride(from: 0.0, to: 1.0, by: 0.1) {
        guard let pixelColor = pixelReader.pixelColor(percentage: CGPoint(x: x, y: y)) else {
          Log.verbose(context: "Favicon", "Failed to get pixel color at (\(x), \(y))")
          return false
        }
        if pixelColor.alpha < 0.1 {
          effectiveTransparentCount += 1
        } else if pixelColor.isEffectivelyBlack {
          effectiveBlackCount += 1
        } else if pixelColor.isEffectivelyWhite {
          effectiveWhiteCount += 1
        } else {
          colorCount += 1
        }
      }
    }
    let greyscaleCount = effectiveWhiteCount + effectiveBlackCount
    guard colorCount / max(1, greyscaleCount) < 0.05 else { return false }
    return greyscaleCount - max(effectiveWhiteCount, effectiveBlackCount) < 0.05
  }
}

import SwiftUI

import HelloCore

#if canImport(CoreImage)
import UniformTypeIdentifiers
import CoreImage

#if os(macOS)
extension NSImage: @unchecked Sendable {}

public extension NSImage {
  var cgImage: CGImage? {
    cgImage(forProposedRect: nil, context: nil, hints: nil)
  }
  
  var data: Data? {
    tiffRepresentation
  }
}
#else
extension UIImage: @unchecked Sendable {}

public extension UIImage {
  var data: Data? {
    pngData()
  }
}
#endif

public extension CGImage {
  var data: Data? {
    guard let mutableData = CFDataCreateMutable(nil, 0),
          let destination = CGImageDestinationCreateWithData(mutableData, utType ?? UTType.png.identifier as CFString, 1, nil) else { return nil }
    CGImageDestinationAddImage(destination, self, nil)
    guard CGImageDestinationFinalize(destination) else { return nil }
    return mutableData as Data
  }
}

@globalActor final public actor ImageProcessingActor: GlobalActor {
  public static let shared: ImageProcessingActor = ImageProcessingActor()
}

@ImageProcessingActor
public class ImageProcessor {
  
  public enum HelloImageError: Error, Sendable {
    case invalidData
    case failedToCreateDestination
    case failedToResize
  }
  
  public enum HelloImageFormat: Codable, Sendable {
    case jpg
    case png
    case heic
    case gif
    case tiff
    
    public var utType: UTType {
      switch self {
      case .jpg: .jpeg
      case .png: .png
      case .heic: .heic
      case .gif: .gif
      case .tiff: .tiff
      }
    }
  }
  
//  public static func resize(imageData: Data, maxSize: Int, format: HelloImageFormat = .heic) throws -> Data {
//    let maxSize = CGFloat(maxSize)
//    guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
//          let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
//    else {
//      Log.error("Failed to create source", context: "Image Resize")
//      throw HelloImageError.failedToCreateDestination
//    }
//    
//    var size = CGSize(width: image.width, height: image.height)
//    
//    if size.width > maxSize && size.width >= size.height {
//      let scale = maxSize / size.width
//      size.width *= scale
//      size.height *= scale
//    } else if size.height > maxSize && size.height >= size.width {
//      let scale = maxSize / size.height
//      size.width *= scale
//      size.height *= scale
//    }
//    
//    let intSize = IntSize(width: Int(size.width), height: Int(size.height))
//    
//    let context = CGContext(data: nil,
//                            width: intSize.width,
//                            height: intSize.height,
//                            bitsPerComponent: image.bitsPerComponent,
//                            bytesPerRow: 0,
//                            space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
//                            bitmapInfo: image.bitmapInfo.rawValue)
//    context?.interpolationQuality = .default
//    context?.draw(image, in: CGRect(origin: .zero, size: size))
//    
//    guard let scaledImage = context?.makeImage() else {
//      Log.error("Failed to create image", context: "Image Resize")
//      throw HelloImageError.failedToCreateDestination
//    }
//    
//    guard let data = scaledImage.data else {
//      Log.error("Failed to create data", context: "Image Resize")
//      throw HelloImageError.failedToCreateDestination
//    }
//    
//    return data
//  }
  
  public static func resize(imageData: Data, maxSize: Int, format: HelloImageFormat = .heic) throws -> Data {
    guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) else {
      Log.error("Failed to create source", context: "Image Resize")
      throw HelloImageError.failedToCreateDestination
    }
    
    let mutableData = NSMutableData()
    guard let destination = CGImageDestinationCreateWithData(
      mutableData,
      format.utType.identifier as CFString,
      1,
      [:] as CFDictionary)
    else {
      Log.error("Failed to create destination", context: "Image Resize")
      throw HelloImageError.failedToCreateDestination
    }

    CGImageDestinationAddImageFromSource(destination, imageSource, 0, [
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageDestinationImageMaxPixelSize: maxSize,
      kCGImageDestinationLossyCompressionQuality: 0.8,
    ] as CFDictionary)
    guard CGImageDestinationFinalize(destination), !mutableData.isEmpty else {
      Log.error("Failed to finalize destination", context: "Image Resize")
      throw HelloImageError.failedToResize
    }
    return mutableData as Data
  }
  
  public static func processImageData(imageData: Data, maxSize: CGFloat, allowTransparency: Bool = true) async -> Data {
#if os(iOS) || os(tvOS) || os(visionOS)
    guard let image = UIImage(data: imageData, scale: 1)
    else { return imageData }
    var size = CGSize(width: floor(image.size.width), height: floor(image.size.height))
#else
    guard let image = NSImage(data: imageData)?.representations.first else { return imageData }
    var size = CGSize(width: image.pixelsWide, height: image.pixelsHigh)
#endif
    
    if size.width > maxSize && size.width >= size.height {
      let scale = maxSize / size.width
      size.width *= scale
      size.height *= scale
    } else if size.height > maxSize && size.height >= size.width {
      let scale = maxSize / size.height
      size.width *= scale
      size.height *= scale
    }
    
#if os(iOS) || os(tvOS) || os(visionOS)
    let renderer = UIGraphicsImageRenderer(size: size,
                                           format: UIGraphicsImageRendererFormat() +& { $0.scale = 1 })
    let resizedImageData: Data
    if allowTransparency {
      resizedImageData = renderer.pngData { context in
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
      }
    } else {
      resizedImageData = renderer.jpegData(withCompressionQuality: 0.5) { context in
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
      }
    }
    
    return resizedImageData
#else
    if let bitmapRep = NSBitmapImageRep(
      bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height),
      bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
      colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
    ) {
      bitmapRep.size = CGSize(width: size.width, height: size.height)
      NSGraphicsContext.saveGraphicsState()
      NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
      image.draw(in: NSRect(x: 0, y: 0, width: size.width, height: size.height),
                 from: .zero,
                 operation: .copy,
                 fraction: 1.0,
                 respectFlipped: true,
                 hints: [:])
      NSGraphicsContext.restoreGraphicsState()
      return bitmapRep.representation(using: .png, properties: [.compressionFactor: 0.8]) ?? imageData
    }
    
    return imageData
#endif
  }
  
  private static func frameDuration(for frame: Int, in source: CGImageSource) -> TimeInterval? {
    let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, frame, nil)
    let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
    defer {
      gifPropertiesPointer.deallocate()
    }
    let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
    if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
      return nil
    }
    let gifProperties = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
    var delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                          Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
                                     to: AnyObject.self)
    if delayWrapper.doubleValue == 0 {
      delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                        Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()),
                                   to: AnyObject.self)
    }
    
    if let delay = delayWrapper as? Double, delay > 0 {
      return delay
    } else {
      return nil
    }
  }
  
  public static func animatedFrames(from imageData: Data, maxSize: CGFloat? = nil) async -> [AnimatedImageFrame]? {
    guard let source = CGImageSourceCreateWithData(imageData as CFData, [:] as CFDictionary) else { return nil }
    let frameCount = CGImageSourceGetCount(source)
    guard frameCount > 1 else { return nil }
    var frames: [AnimatedImageFrame] = []
    for i in 0..<frameCount {
      if let cgFrame = CGImageSourceCreateImageAtIndex(source, i, nil),
         var data = cgFrame.data {
        if let maxSize {
          data = await processImageData(imageData: data, maxSize: maxSize, allowTransparency: true)
        }
        if let image = NativeImage(data: data) {
          frames.append(AnimatedImageFrame(image: image, duration: frameDuration(for: i, in: source) ?? 0.033))
        }
      }
    }
    guard frames.count > 1 else { return nil }
    return frames
  }
  
  public static func generateGif(photos: [NativeImage]) -> Data? {
    let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
    let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.8]]
    if let mutableData = CFDataCreateMutable(nil, 0),
       let destination = CGImageDestinationCreateWithData(mutableData, UTType.gif.identifier as CFString, photos.count, nil) {
      CGImageDestinationSetProperties(destination, fileProperties as CFDictionary?)
      for photo in photos {
        if let cgImage = photo.cgImage {
          CGImageDestinationAddImage(destination, cgImage, gifProperties as CFDictionary?)
        }
      }
      guard CGImageDestinationFinalize(destination) else { return nil }
      return mutableData as Data
    }
    return nil
  }
}


#else
public class ImageProcessor {
  
  public static func processImageData(imageData: Data, maxSize: CGFloat, allowTransparency: Bool = false) async -> Data {
    imageData
  }
  
  public static func animatedFrames(from imageData: Data, maxSize: CGFloat? = nil) async -> [AnimatedImageFrame]? {
    nil
  }
  
  public static func generateGif(photos: [NativeImage]) -> Data? {
    nil
  }
}

#endif

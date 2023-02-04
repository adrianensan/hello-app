import SwiftUI

#if os(iOS)
public typealias NativeImage = UIImage
#elseif os(macOS)
public typealias NativeImage = NSImage
extension NativeImage {
  convenience init(cgImage: CGImage) {
    self.init(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
  }
}
#else
public struct FakeImage {
  init()
}
public typealias NativeImage = FakeImage
#endif

public extension Image {
  init(_ image: NativeImage) {
#if canImport(UIKit)
    self.init(uiImage: image)
#elseif canImport(AppKit)
    self.init(nsImage: image)
#else
    self.init("")
#endif
  }
}

public extension NativeImage {
  static func create(from cgImage: CGImage) -> NativeImage {
#if canImport(UIKit)
    NativeImage(cgImage: cgImage)
#elseif canImport(AppKit)
    NativeImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
#else
    NativeImage.init("")
#endif
  }
}

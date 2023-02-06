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
  init() {}
  
  init?(named: String) {}
}
public typealias NativeImage = FakeImage
#endif

public extension Image {
  init(_ image: NativeImage) {
#if os(iOS)
    self.init(uiImage: image)
#elseif os(macOS)
    self.init(nsImage: image)
#else
    self.init("")
#endif
  }
}

public extension NativeImage {
  static func create(from cgImage: CGImage) -> NativeImage {
#if os(iOS)
    NativeImage(cgImage: cgImage)
#elseif os(macOS)
    NativeImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
#else
    NativeImage()
#endif
  }
}

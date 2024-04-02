import SwiftUI

#if os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
public typealias NativeImage = UIImage
extension UIImage: @unchecked Sendable {}
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
  init(nativeImage: NativeImage) {
#if os(iOS)
    self.init(uiImage: nativeImage)
#elseif os(macOS)
    self.init(nsImage: nativeImage)
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

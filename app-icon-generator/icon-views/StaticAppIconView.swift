import SwiftUI
#if canImport(CoreImage)
import CoreImage.CIFilterBuiltins
#endif

import HelloCore
import HelloApp

public struct StaticAppIconView: View {
  
  private static var _image: NativeImage?
  private var image: NativeImage {
    Self._image ?? generateDitheredImage() +& { Self._image = $0 }
  }
  
  private func generateDitheredImage() -> NativeImage {
#if canImport(CoreImage)
    let originalSize: CGFloat = 256
    guard let cgImage = ImageRendererer.renderCGImage(view: Color.black.mask(icon).background(HelloColor.light.swiftuiColor),
                                                      size: CGSize(width: originalSize, height: originalSize))
    else { return NativeImage() }
    
    let ciImage = CIImage(cgImage: cgImage)
    
    let filter = CIFilter.dither() +& {
      $0.inputImage = ciImage
      $0.intensity = 7
    }
    
    guard let outputImage = filter.outputImage,
          let outputCGImage = CIContext().createCGImage(outputImage, from: outputImage.extent)
    else { return NativeImage() }
    
    return NativeImage.create(from: outputCGImage)
#else
    return NativeImage()
#endif
  }
  
  private let icon: AnyView
  
  public init(icon: some View) {
    self.icon = AnyView(icon)
  }
  
  public var body: some View {
    Image(nativeImage: image)
      .resizable()
      .aspectRatio(contentMode: .fill)
  }
}

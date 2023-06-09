import SwiftUI
#if canImport(CoreImage)
import CoreImage.CIFilterBuiltins
#endif

import HelloCore

@MainActor
public struct PixelatedIconView: View {
  
  private static var _image: NativeImage?
  private var image: NativeImage {
    Self._image ?? generateDitheredImage() +& { Self._image = $0 }
  }
  
  private func generateDitheredImage() -> NativeImage {
    #if canImport(CoreImage)
    let originalSize: CGFloat = 800
    guard let cgImage = ImageRendererer.renderCGImage(view: characterView,
                                                    size: CGSize(width: originalSize, height: originalSize))
    else { return NativeImage() }
            
    let ciImage = CIImage(cgImage: cgImage)
    
    let filter = CIFilter.pixellate() +& {
      $0.inputImage = ciImage
      $0.scale = 40
      $0.center = CGPoint(x: 400, y: 400)
    }
    
    guard let outputImage = filter.outputImage,
          let outputCGImage = CIContext().createCGImage(outputImage, from: outputImage.extent)
    else { return NativeImage() }
    
    return NativeImage.create(from: outputCGImage)
    #else
    return NativeImage()
    #endif
  }
  
  private let characterView: AnyView
  
  public init<CharacterView: View>(characterView: CharacterView) {
    self.characterView = AnyView(characterView)
  }
  
  public var body: some View {
    Image(image)
      .resizable()
      .aspectRatio(contentMode: .fill)
      .background(HelloColor.black.swiftuiColor)
  }
}

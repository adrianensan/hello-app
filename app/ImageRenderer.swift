import SwiftUI

import HelloCore

@MainActor
public enum ImageRendererer {
#if os(iOS)
  public static func render<Content: View>(view: Content, size: CGSize) -> NativeImage? {
    let controller = UIHostingController(rootView: view
      .frame(width: size.width, height: size.height)
      .drawingGroup()
      .ignoresSafeArea())
    guard let view = controller.view else { return nil }
    
    let targetSize = size
    view.frame.size = targetSize
    view.backgroundColor = .clear
    
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    
    var failed = false
    let image = renderer.image { _ in
      guard view.drawHierarchy(in: view.frame, afterScreenUpdates: true) else {
        return failed = true
      }
    }
    return failed ? nil : image
  }
  
  public static func renderCGImage<Content: View>(view: Content, size: CGSize) -> CGImage? {
    let image: NativeImage? = render(view: view, size: size)
    return image?.cgImage
  }
#elseif os(macOS)
  private static func renderBitmapImage<Content: View>(view content: Content, size: CGSize) -> NSBitmapImageRep? {
    let view = NSHostingView(rootView: content
      .frame(width: size.width, height: size.height)
      .drawingGroup()
      .ignoresSafeArea())
    view.frame = CGRect(origin: .zero, size: size)
    
    guard let imageRepresentation = view.bitmapImageRepForCachingDisplay(in: view.frame) else { return nil }
    
    view.cacheDisplay(in: view.frame, to: imageRepresentation)
    
    return imageRepresentation
  }
  
  public static func renderData<Content: View>(view content: Content, size: CGSize, sizeIsPixels: Bool) -> Data? {
    let screenSale = NSScreen.main!.backingScaleFactor
    var targetSize = NSSize(width: size.width, height: size.height)
    if sizeIsPixels { targetSize = targetSize / screenSale }
    
    guard let nsImagerep = renderBitmapImage(view: content, size: size),
          let newImage = NSBitmapImageRep(bitmapDataPlanes: nil,
                                          pixelsWide: Int(size.width * (sizeIsPixels ? 1 : screenSale)),
                                          pixelsHigh: Int(size.height * (sizeIsPixels ? 1 : screenSale)),
                                          bitsPerSample: 8, samplesPerPixel: 4,
                                          hasAlpha: true, isPlanar: false,
                                          colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)
    else { return nil }
    newImage.size = targetSize
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: newImage)? +& {
      $0.shouldAntialias = true
      $0.imageInterpolation = .high
    }
    nsImagerep.draw(in: NSRect(origin: .zero, size: targetSize))
    NSGraphicsContext.restoreGraphicsState()
    return newImage.representation(using: .png, properties: [.compressionFactor: 0.9])
  }
  
  public static func renderCGImage<Content: View>(view content: Content, size: CGSize) -> CGImage? {
    let nsImagerep = renderBitmapImage(view: content, size: size)
    return nsImagerep?.cgImage
  }
  
  public static func render<Content: View>(view content: Content, size: CGSize) -> NSImage? {
    guard let imageData: Data = renderData(view: content, size: size, sizeIsPixels: false) else { return nil }
    return NSImage(data: imageData)
  }
#else
  public static func render<Content: View>(view content: Content, size: CGSize) -> NativeImage? {
    return nil
  }
  public static func renderCGImage<Content: View>(view content: Content, size: CGSize) -> CGImage? {
    return nil
  }
#endif
}

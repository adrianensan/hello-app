#if os(iOS) || os(macOS)
import Foundation
import AVKit

import HelloCore

enum VideoThumbnailGeneratorError: Error {
  case fail
}

public enum VideoThumbnailGenerator {
  public static func imageFromVideo(url: URL) async throws -> NativeImage {
    let asset = AVURLAsset(url: url)
    
    let assetIG = AVAssetImageGenerator(asset: asset)
    assetIG.appliesPreferredTrackTransform = true
    assetIG.apertureMode = .encodedPixels
    
    let image: NativeImage = try await withCheckedThrowingContinuation { continuation in
      assetIG.generateCGImagesAsynchronously(forTimes: [NSValue(time: .zero)]) { _, cgImage, _, result, error in
        if let error = error {
          Log.error(context: "Video Thumbnail Generator", "Failed to create thumbnail for \(url.absoluteString), Error: \(error.localizedDescription)")
          continuation.resume(with: .failure(error))
        } else if let cgImage = cgImage {
          continuation.resume(with: .success(NativeImage(cgImage: cgImage)))
        } else {
          Log.error(context: "Video Thumbnail Generator", "Failed to create thumbnail for \(url.absoluteString)")
          continuation.resume(with: .failure(VideoThumbnailGeneratorError.fail))
        }
      }
    }
    
    Log.info(context: "Video Thumbnail Generator", "Success")
    return image
  }
}
#endif

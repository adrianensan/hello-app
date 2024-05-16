import SwiftUI

import HelloCore

@MainActor
public struct AnimatedHelloImageView: View {
  
  @Environment(\.theme) private var theme
  
  @State private var currentFrame: NativeImage
  private var imageFrames: [AnimatedImageFrame]
  private let resizeMode: ContentMode
  
  public init(images: [AnimatedImageFrame], resizeMode: ContentMode = .fit) {
    self.imageFrames = images
    currentFrame = images.first?.image ?? NativeImage()
    self.resizeMode = resizeMode
  }
  
  public var body: some View {
    Image(nativeImage: currentFrame)
      .resizable()
      .aspectRatio(contentMode: resizeMode)
      .task {
        while true {
          for frame in imageFrames {
            currentFrame = frame.image
            do {
              try await Task.sleep(seconds: frame.duration)
            } catch {
              return
            }
          }
        }
      }
  }
}

@MainActor
public struct HelloImageView<CustomView: View, Fallback: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.isActive) private var isActive
  
  private let model: HelloImageModel
  private let resizeMode: ContentMode
  private let custom: (@MainActor (NativeImage) -> CustomView)?
  private let fallback: @MainActor () -> Fallback
  
  fileprivate init(_ source: HelloImageSource,
                   variant: HelloImageVariant = .original,
                   resizeMode: ContentMode = .fit,
                   custom: (@MainActor (NativeImage) -> CustomView)?,
                   fallback: @MainActor @escaping () -> Fallback) {
    model = .model(for: source, variant: variant)
    self.resizeMode = resizeMode
    self.custom = custom
    self.fallback = fallback
  }
  
  public init(_ source: HelloImageSource,
              variant: HelloImageVariant = .original,
              resizeMode: ContentMode = .fit,
              @ViewBuilder custom: @MainActor @escaping (NativeImage) -> CustomView,
              fallback: @MainActor @escaping () -> Fallback) {
    model = .model(for: source, variant: variant)
    self.resizeMode = resizeMode
    self.custom = custom
    self.fallback = fallback
  }
  
  public var body: some View {
    Group {
      if isActive, let frames = model.frames {
        AnimatedHelloImageView(images: frames)
          .dimForTheme()
      } else if let image = model.image {
        if let custom {
          custom(image)
            .environment(model)
        } else {
          Image(nativeImage: image)
            .resizable()
            .aspectRatio(contentMode: resizeMode)
            .dimForTheme()
        }
      } else {
        fallback()
      }
    }
  }
}

public extension HelloImageView where Fallback == Color {
  init(_ source: HelloImageSource,
       variant: HelloImageVariant = .original,
       resizeMode: ContentMode = .fit,
       @ViewBuilder custom: @MainActor @escaping (NativeImage) -> CustomView) {
    self.init(source,
              variant: variant,
              resizeMode: resizeMode,
              custom: custom,
              fallback: { Color.clear })
  }
}

public extension HelloImageView where CustomView == EmptyView {
  init(_ source: HelloImageSource,
       variant: HelloImageVariant = .original,
       resizeMode: ContentMode = .fit,
       fallback: @MainActor @escaping () -> Fallback) {
    self.init(source,
              variant: variant,
              resizeMode: resizeMode,
              custom: nil,
              fallback: fallback)
  }
}

public extension HelloImageView where CustomView == EmptyView, Fallback == Color {
  init(_ source: HelloImageSource,
       variant: HelloImageVariant = .original,
       resizeMode: ContentMode = .fit) {
    self.init(source,
              variant: variant,
              resizeMode: resizeMode,
              custom: nil,
              fallback: { Color.clear })
  }
}

@MainActor
public struct HelloFallbackImageView: View {
  
  public struct HelloImageOption: Sendable {
    var imageSource: HelloImageSource
    var variant: HelloImageVariant
    
    public init(imageSource: HelloImageSource, variant: HelloImageVariant) {
      self.imageSource = imageSource
      self.variant = variant
    }
  }
  
  @Environment(\.isActive) private var isActive
  
  private let imageOptions: [HelloImageModel]
  private let resizeMode: ContentMode
  
  public init(options: [HelloImageOption], resizeMode: ContentMode = .fit) {
    imageOptions = options.map { .model(for: $0.imageSource, variant: $0.variant) }
    self.resizeMode = resizeMode
  }
  
  private var image: NativeImage? {
    imageOptions.first { $0.image != nil }?.image
  }
  
  private var frames: [AnimatedImageFrame]? {
    imageOptions.first { $0.frames != nil }?.frames
  }
  
  public var body: some View {
    if isActive, let frames {
      AnimatedHelloImageView(images: frames)
        .dimForTheme()
    } else if let image {
      Image(nativeImage: image)
        .resizable()
        .aspectRatio(contentMode: resizeMode)
        .dimForTheme()
    } else {
      Color.clear
    }
  }
}

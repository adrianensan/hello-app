import SwiftUI

import HelloCore

@MainActor
fileprivate struct ViewableImageModifier: ViewModifier {
  
  @Environment(HelloWindowModel.self) private var windowModel
  
  @State private var isViewing = false
  @NonObservedState private var globalFrame: CGRect?
  
  private let imageOptions: [HelloImageOption]
  private let cornerRadius: CGFloat
  
  init(imageOptions: [HelloImageOption], cornerRadius: CGFloat?) {
    self.imageOptions = imageOptions
    self.cornerRadius = cornerRadius ?? 0
  }
  
  func body(content: Content) -> some View {
    content
      .opacity(isViewing ? 0 : 1)
      .animation(nil, value: isViewing)
      .readFrame(to: $globalFrame)
      .simultaneousGesture(TapGesture()
        .onEnded { _ in
          var fullImageOptions: [HelloImageOption] = []
          for imageOption in imageOptions {
            if imageOption.variant != .original {
              fullImageOptions.append(HelloImageOption(imageSource: imageOption.imageSource, variant: .original))
            }
            fullImageOptions.append(imageOption)
          }
          
          #if os(iOS)
          windowModel.showPopup(onDismiss: { isViewing = false }) {
            ImageViewer(options: fullImageOptions, originalFrame: globalFrame, cornerRadius: cornerRadius)
          }
          #endif
          isViewing = true
          ButtonHaptics.buttonFeedback()
        })
  }
}

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

public struct HelloImageOption: Equatable, Identifiable, Sendable {
  public var imageSource: HelloImageSource
  public var variant: HelloImageVariant
  
  public init(imageSource: HelloImageSource, variant: HelloImageVariant) {
    self.imageSource = imageSource
    self.variant = variant
  }
  
  public var id: String { HelloImageID(source: imageSource, variant: variant).id }
}

public struct HelloImageView<CustomView: View, Fallback: View>: View {
  
  public enum HelloImageLoadType: Sendable {
    case async
    case sync
  }
  
  @Environment(\.theme) private var theme
  @Environment(\.isActive) private var isActive
  
  @State private var imageModels: [HelloImageModel] = []
  private var imageOptions: [HelloImageOption]
  private let load: HelloImageLoadType
  private let viewable: Bool
  private let cornerRadius: CGFloat?
  private let resizeMode: ContentMode
  private let cache: HelloImageCache?
  private let custom: (@MainActor (NativeImage) -> CustomView)?
  private let fallback: @MainActor () -> Fallback
  
  public init(options: [HelloImageOption],
              load: HelloImageLoadType = .async,
              viewable: Bool = false,
              cornerRadius: CGFloat? = nil,
              resizeMode: ContentMode = .fit,
              cache: HelloImageCache? = nil,
              custom: (@MainActor (NativeImage) -> CustomView)?,
              fallback: @MainActor @escaping () -> Fallback) {
    imageOptions = options
    self.load = load
    //    imageModels = imageOptions.map { .model(for: $0.imageSource, variant: $0.variant) }
    self.viewable = viewable
    self.cornerRadius = cornerRadius
    self.resizeMode = resizeMode
    self.cache = cache
    self.custom = custom
    self.fallback = fallback
  }
  
  public init(_ source: HelloImageSource,
              variant: HelloImageVariant = .original,
              load: HelloImageLoadType = .async,
              viewable: Bool = false,
              cornerRadius: CGFloat? = nil,
              resizeMode: ContentMode = .fit,
              cache: HelloImageCache? = nil,
              @ViewBuilder custom: @MainActor @escaping (NativeImage) -> CustomView,
              fallback: @MainActor @escaping () -> Fallback) {
    self.init(options: [HelloImageOption(imageSource: source, variant: variant)],
              load: load,
              viewable: viewable,
              cornerRadius: cornerRadius,
              resizeMode: resizeMode,
              cache: cache,
              custom: custom,
              fallback: fallback)
  }
  
  fileprivate init(_ source: HelloImageSource,
                   variant: HelloImageVariant = .original,
                   load: HelloImageLoadType = .async,
                   viewable: Bool = false,
                   cornerRadius: CGFloat? = nil,
                   resizeMode: ContentMode,
                   cache: HelloImageCache? = nil,
                   custom: (@MainActor (NativeImage) -> CustomView)?,
                   fallback: @MainActor @escaping () -> Fallback) {
    self.init(options: [HelloImageOption(imageSource: source, variant: variant)],
              load: load,
              viewable: viewable,
              cornerRadius: cornerRadius,
              resizeMode: resizeMode,
              cache: cache,
              custom: custom,
              fallback: fallback)
  }
  
  private var model: HelloImageModel? {
    imageModels.first { $0.image != nil }
  }
  
  private var image: NativeImage? {
    model?.image
  }
  
  private var frames: [AnimatedImageFrame]? {
    model?.frames
  }
  
  public var body: some View {
    Group {
      if isActive, let frames {
        AnimatedHelloImageView(images: frames)
          .dimForTheme()
      } else if let image {
        if let custom, let model {
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
    }.ifLet(cornerRadius) { view, cornerRadius in
      view
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .strokeBorder(theme.foreground.primary.style.opacity(0.2), lineWidth: 0.5))
    }.if(viewable) {
      $0.modifier(ViewableImageModifier(imageOptions: imageOptions, cornerRadius: cornerRadius))
    }.onChange(of: imageOptions, initial: true) {
      var imageModels: [HelloImageModel] = []
      for imageOption in imageOptions {
        let model: HelloImageModel = .model(for: imageOption.imageSource, variant: imageOption.variant)
        switch load {
        case .async:
          model.loadAsync()
        case .sync:
          model.loadSync()
        }
        imageModels.append(model)
        cache?.imageModelCache[imageOption.id] = model
        if imageModels.last?.image != nil {
          break
        }
      }
      self.imageModels = imageModels
    }
  }
}

public extension HelloImageView where Fallback == Color {
  init(_ source: HelloImageSource,
       variant: HelloImageVariant = .original,
       load: HelloImageLoadType = .async,
       viewable: Bool = false,
       cornerRadius: CGFloat? = nil,
       resizeMode: ContentMode = .fit,
       cache: HelloImageCache? = nil,
       @ViewBuilder custom: @MainActor @escaping (NativeImage) -> CustomView) {
    self.init(source,
              variant: variant,
              load: load,
              viewable: viewable,
              cornerRadius: cornerRadius,
              resizeMode: resizeMode,
              cache: cache,
              custom: custom,
              fallback: { Color.clear })
  }
}

public extension HelloImageView where CustomView == EmptyView {
  init(_ source: HelloImageSource,
       variant: HelloImageVariant = .original,
       load: HelloImageLoadType = .async,
       viewable: Bool = false,
       cornerRadius: CGFloat? = nil,
       resizeMode: ContentMode = .fit,
       cache: HelloImageCache? = nil,
       fallback: @MainActor @escaping () -> Fallback) {
    self.init(source,
              variant: variant,
              load: load,
              viewable: viewable,
              cornerRadius: cornerRadius,
              resizeMode: resizeMode,
              cache: cache,
              custom: nil,
              fallback: fallback)
  }
  
  init(options: [HelloImageOption],
       load: HelloImageLoadType = .async,
       viewable: Bool = false,
       cornerRadius: CGFloat? = nil,
       resizeMode: ContentMode = .fit,
       cache: HelloImageCache? = nil,
       fallback: @MainActor @escaping () -> Fallback) {
    self.init(options: options,
              load: load,
              viewable: viewable,
              cornerRadius: cornerRadius,
              resizeMode: resizeMode,
              cache: cache,
              custom: nil,
              fallback: fallback)
  }
}

public extension HelloImageView where CustomView == EmptyView, Fallback == Color {
  init(_ source: HelloImageSource,
       variant: HelloImageVariant = .original,
       load: HelloImageLoadType = .async,
       viewable: Bool = false,
       cornerRadius: CGFloat? = nil,
       resizeMode: ContentMode = .fit,
       cache: HelloImageCache? = nil) {
    self.init(source,
              variant: variant,
              load: load,
              viewable: viewable,
              cornerRadius: cornerRadius,
              resizeMode: resizeMode,
              cache: cache,
              custom: nil,
              fallback: { Color.clear })
  }
  
  init(options: [HelloImageOption],
       load: HelloImageLoadType = .async,
       viewable: Bool = false,
       cornerRadius: CGFloat? = nil,
       resizeMode: ContentMode = .fit,
       cache: HelloImageCache? = nil) {
    self.init(options: options,
              load: load,
              viewable: viewable,
              cornerRadius: cornerRadius,
              resizeMode: resizeMode,
              cache: cache,
              custom: nil,
              fallback: { Color.clear })
  }
}

//public struct HelloFallbackImageView: View {
//  
//  public struct HelloImageOption: Equatable, Sendable {
//    public var imageSource: HelloImageSource
//    public var variant: HelloImageVariant
//    
//    public init(imageSource: HelloImageSource, variant: HelloImageVariant) {
//      self.imageSource = imageSource
//      self.variant = variant
//    }
//  }
//  
//  @Environment(\.isActive) private var isActive
//  
//  private let imageOptions: [HelloImageModel]
//  private let resizeMode: ContentMode
//  
//  public init(options: [HelloImageOption], resizeMode: ContentMode = .fit) {
//    imageOptions = options.map { .model(for: $0.imageSource, variant: $0.variant) }
//    self.resizeMode = resizeMode
//  }
//  
//  private var image: NativeImage? {
//    imageOptions.first { $0.image != nil }?.image
//  }
//  
//  private var frames: [AnimatedImageFrame]? {
//    imageOptions.first { $0.frames != nil }?.frames
//  }
//  
//  public var body: some View {
//    if isActive, let frames {
//      AnimatedHelloImageView(images: frames)
//        .dimForTheme()
//    } else if let image {
//      Image(nativeImage: image)
//        .resizable()
//        .aspectRatio(contentMode: resizeMode)
//        .dimForTheme()
//    } else {
//      Color.clear
//    }
//  }
//}

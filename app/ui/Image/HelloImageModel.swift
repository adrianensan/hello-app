import Foundation
import Observation

import HelloCore

public struct HelloImageID {
  public var source: HelloImageSource
  public var variant: HelloImageVariant
  
  init(source: HelloImageSource, variant: HelloImageVariant) {
    self.source = source
    self.variant = variant
  }
    
  public var id: String { "\(source.id)-\(variant.id)" }
}

public enum HelloImageSource: Hashable, Sendable, Identifiable {
  case asset(named: String)
  case resource(bundle: Bundle = .main, fileName: String)
  case url(String)
  case remoteURL(String)
  case favicon(String)
  case nativeImage(NativeImage)
  case frames([AnimatedImageFrame])
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
  
  public var id: String {
    switch self {
    case .asset(let named):
      "asset-\(named)"
    case .resource(let bundle, let fileName):
      "resource-\(bundle)-\(fileName)"
    case .url(let url):
      "file-url-\(url)"
    case .remoteURL(let url):
      "remote-url-\(url)"
    case .favicon(let url):
      if !HelloURL(string: url).host.isEmpty {
        "favicon-url-\(HelloURL(string: url).host)"
      } else {
        "favicon-url-\(url)"
      }
    case .nativeImage(let nativeImage):
      "static-image--\(ObjectIdentifier(nativeImage).hashValue)"
    case .frames(let frames):
      "animated-image-\(frames.count)-\((frames.first?.image).map { ObjectIdentifier($0).hashValue } ?? 0)"
    }
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

public struct AnimatedImageFrame: Sendable, Hashable {
  public var image: NativeImage
  public var duration: TimeInterval
}

@globalActor final public actor HellosActor: GlobalActor {
    public static var shared: HellosActor = HellosActor()
    
    public typealias ActorType = HellosActor
    
    
}

@MainActor
@Observable
class HelloImageModel {
  private static var models: [String: Weak<HelloImageModel>] = [:]
  public static func model(for imageSource: HelloImageSource, variant: HelloImageVariant = .original) -> HelloImageModel {
    let id = HelloImageID(source: imageSource, variant: variant).id
    if let model = models[id]?.value {
      //      if model.image == nil && !model.isLoading {
      //        Task { try await model.load() }
      //      }
      return model
    } else {
      let model = HelloImageModel(imageSource: imageSource, variant: variant)
      models[id] = Weak(value: model)
      return model
    }
  }
  
  var image: NativeImage?
  var frames: [AnimatedImageFrame]?
  private let imageSource: HelloImageSource
  
  private init(imageSource: HelloImageSource, variant: HelloImageVariant) {
    self.imageSource = imageSource
    switch imageSource {
    case .asset(let named):
      image = NativeImage(named: named)
    case .resource(let bundle, let fileName):
      guard let bundleURL = bundle.url(for: .any(fileName: fileName)),
            let data = try? Data(contentsOf: bundleURL),
            let nativeImage = NativeImage(data: data)
      else { return }
      image = nativeImage
      Task { await loadFrames(from: data) }
    case .url(let fileURL):
      guard let url = URL(string: fileURL),
            let data = try? Data(contentsOf: url),
            let nativeImage = NativeImage(data: data)
      else { return }
      image = nativeImage
      Task { await loadFrames(from: data) }
    case .remoteURL(let url):
      if let cachedImageData = Persistence.initialValue(.cacheRemoteIamge(url: url, variant: variant)) {
        image = NativeImage(data: cachedImageData)
        Task { await loadFrames(from: cachedImageData) }
      } else if let cachedOriginalImageData = Persistence.initialValue(.cacheRemoteIamge(url: url)) ?? Persistence.initialValue(.tempDownload(url: url)) {
        Task {
          let resizedImageData = await ImageProcessor.processImageData(imageData: cachedOriginalImageData, maxSize: CGFloat(variant.size))
          await Persistence.save(resizedImageData, for: .cacheRemoteIamge(url: url, variant: variant))
          image = NativeImage(data: resizedImageData)
          await loadFrames(from: resizedImageData)
        }
      } else {
        Task { [weak self] in
          var imageData = try await HelloImageDownloadManager.main.download(from: url)
          await Persistence.save(imageData, for: .tempDownload(url: url))
          switch variant {
          case .original: ()
          case .thumbnail(let size):
            imageData = await ImageProcessor.processImageData(imageData: imageData, maxSize: CGFloat(size))
          }
          await Persistence.save(imageData, for: .cacheRemoteIamge(url: url, variant: variant))
          guard let self else { return }
          self.image = NativeImage(data: imageData)
          await loadFrames(from: imageData)
        }
      }
    case .favicon(let url):
      var helloURL = HelloURL(string: url)
      helloURL.scheme = .https
      let url = helloURL.root.string
      if let cachedFavicon = Persistence.initialValue(.cacheRemoteFavicon(url: url, variant: variant)) {
        image = NativeImage(data: cachedFavicon)
      } else if var favicon = Persistence.initialValue(.cacheRemoteFavicon(url: url)) {
        Task {
          favicon = await ImageProcessor.processImageData(imageData: favicon, maxSize: CGFloat(variant.size), allowTransparency: true)
          await Persistence.save(favicon, for: .cacheRemoteFavicon(url: url, variant: variant))
          image = NativeImage(data: favicon)
        }
      } else {
        Task { [weak self] in
          var favicon = try await LinkFaviconURLDataParser.main.getFavicon(for: helloURL)
          
          await Persistence.save(favicon, for: .tempDownload(url: url))
          switch variant {
          case .original: ()
          case .thumbnail(let size):
            favicon = await ImageProcessor.processImageData(imageData: favicon, maxSize: CGFloat(size), allowTransparency: true)
          }
          await Persistence.save(favicon, for: .cacheRemoteFavicon(url: url, variant: variant))
          guard let self else { return }
          image = NativeImage(data: favicon)
        }
      }
    case .nativeImage(let nativeImage):
      image = nativeImage
    case .frames(let frames):
      image = frames.first?.image
      self.frames = frames
    }
  }
  
  func loadFrames(from data: Data) async {
    frames = await ImageProcessor.animatedFrames(from: data)
  }
}

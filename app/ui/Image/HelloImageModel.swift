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

@MainActor
@Observable
public class HelloImageModel {
  
  public static var useAppGroup: Bool = false
  
  private static var models: [String: HelloImageModel] = [:]
  private static var weakModels: [String: Weak<HelloImageModel>] = [:]
  public static func model(for imageSource: HelloImageSource, variant: HelloImageVariant = .original) -> HelloImageModel {
    let id = HelloImageID(source: imageSource, variant: variant).id
    if let model = models[id] ?? weakModels[id]?.value {
      return model
    } else {
      let model = HelloImageModel(imageSource: imageSource, variant: variant)
//      weakModels[id] = Weak(value: model)
      switch variant {
      case .original:
        weakModels[id] = Weak(value: model)
      case .thumbnail(let size):
        if size <= 300 {
          models[id] = model
        } else {
          weakModels[id] = Weak(value: model)
        }
      }
      return model
    }
  }
  
  public private(set) var image: NativeImage?
  public private(set) var frames: [AnimatedImageFrame]?
  public let imageSource: HelloImageSource
  
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
      if let cachedImageData = Persistence.initialValue(.cacheRemoteIamge(url: url, variant: variant, useAppGroup: true)) {
        image = NativeImage(data: cachedImageData)
        Task { await loadFrames(from: cachedImageData) }
      } else if let cachedOriginalImageData = Persistence.initialValue(.cacheRemoteIamge(url: url, useAppGroup: true)) ?? Persistence.initialValue(.tempDownload(url: url)) {
        Task {
          let resizedImageData = try await ImageProcessor.resize(imageData: cachedOriginalImageData, maxSize: variant.size)
          await Persistence.save(resizedImageData, for: .cacheRemoteIamge(url: url, variant: variant, useAppGroup: true))
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
            imageData = try await ImageProcessor.resize(imageData: imageData, maxSize: size)
          }
          await Persistence.save(imageData, for: .cacheRemoteIamge(url: url, variant: variant, useAppGroup: true))
          guard let self else { return }
          self.image = NativeImage(data: imageData)
          await loadFrames(from: imageData)
        }
      }
    case .favicon(let url):
      var helloURL = HelloURL(string: url)
      guard helloURL.host.contains(".") && !helloURL.host.hasSuffix(".") else { return }
      helloURL.scheme = .https
      let url = helloURL.root.string
      if let cachedFavicon = Persistence.initialValue(.cacheRemoteIamge(url: url, variant: variant, useAppGroup: true)) {
        image = NativeImage(data: cachedFavicon)
      } else if var favicon = Persistence.initialValue(.cacheRemoteIamge(url: url, useAppGroup: true)) {
        Task {
          favicon = try await ImageProcessor.processImageData(imageData: favicon, maxSize: CGFloat(variant.size))
          await Persistence.save(favicon, for: .cacheRemoteIamge(url: url, variant: variant, useAppGroup: true))
          image = NativeImage(data: favicon)
        }
      } else {
        Task { [weak self] in
          var favicon = try await LinkFaviconURLDataParser.main.getFavicon(for: helloURL)
          
          await Persistence.save(favicon, for: .tempDownload(url: url))
          switch variant {
          case .original: ()
          case .thumbnail(let size):
            favicon = try await ImageProcessor.processImageData(imageData: favicon, maxSize: CGFloat(size))
          }
          await Persistence.save(favicon, for: .cacheRemoteIamge(url: url, variant: variant, useAppGroup: true))
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

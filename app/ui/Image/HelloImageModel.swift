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
  case asset(bundle: Bundle = .main, named: String)
  case resource(bundle: Bundle = .main, fileName: String)
  case url(String)
  case remoteURL(String)
  case favicon(String)
  case nativeImage(NativeImage)
  case frames([AnimatedImageFrame])
  case data(Data)
  
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
    case .data(let data):
      "data-\(data.hashValue)"
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
public class HelloImageCache {
  
  public static var new: HelloImageCache { HelloImageCache() }
  
  var imageModelCache: [String: HelloImageModel] = [:]
}

@MainActor
@Observable
public class HelloImageModel {
  
  public static var useAppGroup: Bool = false
  public static var keepThumbnailsInMemory: Bool = false
  
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
        if size <= 300 && keepThumbnailsInMemory {
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
  private var loadTask: Task<Void, any Error>?
  public let imageSource: HelloImageSource
  public let variant: HelloImageVariant
  public var option: HelloImageOption { HelloImageOption(imageSource: imageSource, variant: variant) }
  
  private init(imageSource: HelloImageSource, variant: HelloImageVariant) {
    self.imageSource = imageSource
    self.variant = variant
    loadTask = nil
    switch imageSource {
    case .asset(let bundle, let named):
      loadTask = Task.detached {
        #if os(macOS)
        let image = bundle.image(forResource: named)
        #else
        let image = NativeImage(named: named, in: bundle, with: nil)
        #endif
        Task { @MainActor [weak self] in
          self?.image = image
        }
      }
    case .resource(let bundle, let fileName):
      loadTask = Task.detached {
        guard let bundleURL = bundle.url(for: .any(fileName: fileName)),
              let data = try? Data(contentsOf: bundleURL),
              let nativeImage = NativeImage(data: data)
        else {
          Log.error("Failed to find bundle image \(fileName)", context: "ImageModel")
          throw HelloError("Failed to find bundle image")
        }
        Task { @MainActor [weak self] in
          self?.image = nativeImage
          await self?.loadFrames(from: data)
        }
      }
    case .url(let fileURL):
      guard let url = URL(string: fileURL),
            let data = try? Data(contentsOf: url),
            let nativeImage = NativeImage(data: data)
      else { return }
      image = nativeImage
      Task { await loadFrames(from: data) }
    case .remoteURL(let url):
      loadTask = Task {
        defer { loadTask = nil }
        let imageData: Data
        if let cachedImageData = await Persistence.value(.cacheRemoteIamge(url: url, variant: variant, useAppGroup: Self.useAppGroup)) {
          imageData = cachedImageData
        } else if let cachedOriginalImageData = await Persistence.value(.cacheRemoteIamge(url: url, useAppGroup: Self.useAppGroup)) {
          imageData = try await ImageProcessor.resize(imageData: cachedOriginalImageData, maxSize: variant.size)
          await Persistence.save(imageData, for: .cacheRemoteIamge(url: url, variant: variant, useAppGroup: Self.useAppGroup))
        } else if let cachedOriginalImageData = await Persistence.value(.tempDownload(url: url)) {
          imageData = try await ImageProcessor.resize(imageData: cachedOriginalImageData, maxSize: variant.size)
          await Persistence.save(imageData, for: .cacheRemoteIamge(url: url, variant: variant, useAppGroup: Self.useAppGroup))
        } else {
          let rawImageData = try await HelloImageDownloadManager.main.download(from: url)
          await Persistence.save(rawImageData, for: .tempDownload(url: url))
          switch variant {
          case .original:
            imageData = rawImageData
          case .thumbnail(let size):
            imageData = try await ImageProcessor.resize(imageData: rawImageData, maxSize: size)
          }
          await Persistence.save(imageData, for: .cacheRemoteIamge(url: url, variant: variant, useAppGroup: Self.useAppGroup))
        }
        self.image = NativeImage(data: imageData)
        await loadFrames(from: imageData)
      }
    case .favicon(let url):
      var helloURL = HelloURL(string: url)
      guard helloURL.host.contains(".") && !helloURL.host.hasSuffix(".") else { return }
      helloURL.scheme = .https
      let url = helloURL.root.string
//      image = NativeImage()
      loadTask = Task {
        defer { loadTask = nil }
        if let cachedFavicon = await Persistence.value(.cacheRemoteIamge(url: url, variant: variant, useAppGroup: Self.useAppGroup)) {
          image = NativeImage(data: cachedFavicon)
        } else if let favicon = await Persistence.value(.cacheRemoteIamge(url: url, useAppGroup: Self.useAppGroup)) {
          //          loadTask = Task {
          //            defer { loadTask = nil }
          let resizedFavicon = try await ImageProcessor.resize(imageData: favicon, maxSize: variant.size)
          await Persistence.save(resizedFavicon, for: .cacheRemoteIamge(url: url, variant: variant, useAppGroup: Self.useAppGroup))
          image = NativeImage(data: resizedFavicon)
          //          }
        } else {
          //          loadTask = Task {
          var favicon = try await LinkFaviconURLDataParser.main.getFavicon(for: helloURL)
          
          await Persistence.save(favicon, for: .tempDownload(url: url))
          switch variant {
          case .original: ()
          case .thumbnail(let size):
            favicon = try await ImageProcessor.resize(imageData: favicon, maxSize: size)
          }
          await Persistence.save(favicon, for: .cacheRemoteIamge(url: url, variant: variant, useAppGroup: Self.useAppGroup))
          image = NativeImage(data: favicon)
          //          }
        }
      }
    case .nativeImage(let nativeImage):
      image = nativeImage
    case .frames(let frames):
      image = frames.first?.image
      self.frames = frames
    case .data(let data):
      image = NativeImage(data: data)
    }
  }
  
  public func load() {
    
  }
  
  public var asyncImage: NativeImage? {
    get async {
      try? await loadTask?.value
      return image
    }
  }
  
  func loadFrames(from data: Data) async {
    frames = await ImageProcessor.animatedFrames(from: data)
  }
}

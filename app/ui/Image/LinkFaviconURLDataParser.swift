import Foundation

import HelloCore

public actor LinkFaviconURLDataParser {
  
  enum LinkPreviewDataParserError: Error {
    case invalidURL
    case fetchError
    case previewDataNotFound
    case alreadyInProgress
    case failedToPrase
    case skip
  }
  
  public static let main = LinkFaviconURLDataParser()
  
  private init() {}
  
  private var inProgress: Set<String> = []
  
  func getFavicon(for helloURL: HelloURL) async throws -> Data {
    var helloURL = helloURL
    helloURL.scheme = .https
    var effectiveHelloURL = helloURL
    guard !inProgress.contains(helloURL.root.string) else { throw LinkPreviewDataParserError.alreadyInProgress }
    inProgress.insert(helloURL.root.string)
    defer { inProgress.remove(helloURL.root.string) }
    
    let pageData: Data
    do {
      pageData = try await HelloImageDownloadManager.main.download(from: effectiveHelloURL.root.string)
    } catch {
      if !effectiveHelloURL.host.starts(with: "www.") {
        effectiveHelloURL.host = "www.\(effectiveHelloURL.host)"
        pageData = try await HelloImageDownloadManager.main.download(from: effectiveHelloURL.root.string)
      } else {
        throw error
      }
    }
    let html = String(data: pageData, encoding: .utf8)
    if html == nil {
      Log.verbose("Failed to parse html")
    }
    
    if let html {
      do {
        let imageURL = try parse(rel: "apple-touch-icon", from: html, url: effectiveHelloURL)
        let imageData = try await HelloImageDownloadManager.main.download(from: imageURL)
        guard let image = NativeImage(data: imageData), image.size.width > 2 else { throw HelloError("Unable to parse image") }
        return imageData
      } catch {
        Log.error(error.localizedDescription)
      }
      
      do {
        let imageURL = try parse(rel: "apple-touch-icon-precomposed", from: html, url: effectiveHelloURL)
        let imageData = try await HelloImageDownloadManager.main.download(from: imageURL)
        guard let image = NativeImage(data: imageData), image.size.width > 2 else { throw HelloError("Unable to parse image") }
        return imageData
      } catch {
        Log.error(error.localizedDescription)
      }
    }
    
    effectiveHelloURL.path = "/apple-touch-icon.png"
    if let imageData = try? await HelloImageDownloadManager.main.download(from: effectiveHelloURL.string),
       let image = NativeImage(data: imageData), image.size.width > 2 {
      return imageData
    }
    
    effectiveHelloURL.path = "/apple-touch-icon-precomposed.png"
    if let imageData = try? await HelloImageDownloadManager.main.download(from: effectiveHelloURL.string),
       let image = NativeImage(data: imageData), image.size.width > 2 {
      return imageData
    }
    
    if let html {
      do {
        let imageURL = try parse(rel: "shortcut icon", from: html, url: effectiveHelloURL)
        let imageData = try await HelloImageDownloadManager.main.download(from: imageURL)
        guard let image = NativeImage(data: imageData), image.size.width > 2 else { throw HelloError("Unable to parse image") }
        return imageData
      } catch {
        Log.error(error.localizedDescription)
      }
      
      do {
        let imageURL = try parse(rel: "icon", from: html, url: effectiveHelloURL)
        let imageData = try await HelloImageDownloadManager.main.download(from: imageURL)
        guard let image = NativeImage(data: imageData), image.size.width > 2 else { throw HelloError("Unable to parse image") }
        return imageData
      } catch {
        Log.error(error.localizedDescription)
      }
    }
    
    effectiveHelloURL.path = "/favicon.ico"
    if let imageData = try? await HelloImageDownloadManager.main.download(from: effectiveHelloURL.string),
       let image = NativeImage(data: imageData), image.size.width > 2 {
      return imageData
    }
    
    let urlString = helloURL.string
    Task {
      await Persistence.atomicUpdate(for: .failedImageDownloads) {
        var copy = $0
        copy[urlString] = epochTime
        return copy
      }
    }
      
    throw LinkPreviewDataParserError.previewDataNotFound
  }
  
  private func parse(rel: String, from html: String, url helloURL: HelloURL) throws -> String {
    let headStartIndex: String.Index
    let headEndIndex: String.Index
    if let headStart = html.range(of: "<head>")?.upperBound {
      headStartIndex = headStart
    } else {
      Log.warning("Failed to find head start, using start index")
      headStartIndex = html.startIndex
    }
    if let headEnd = html.range(of: "</head>", range: headStartIndex..<html.endIndex)?.lowerBound {
      headEndIndex = headEnd
    } else {
      Log.warning("Failed to find head end, using end index")
      headEndIndex = html.endIndex
    }
    guard headStartIndex < headEndIndex else {
      throw HelloError("head element error")
    }
    
    let head = html[headStartIndex..<headEndIndex]
    
    guard let iconRelStartIndex = head.range(of: #"rel="\#(rel)""#)?.upperBound,
          let iconSectionStartIndex = head.range(of: "<link", options: .backwards, range: head.startIndex..<iconRelStartIndex)?.upperBound,
          let iconSectionEndIndex = head.range(of: ">", range: iconSectionStartIndex..<head.endIndex)?.lowerBound else {
      throw HelloError("rel component \(rel) not found")
    }
    
    let iconLine = head[iconSectionStartIndex..<iconSectionEndIndex]
    
    guard let iconStartIndex = iconLine.range(of: "href=\"")?.upperBound,
          let iconEndIndex = iconLine.range(of: "\"", range: iconStartIndex..<iconLine.endIndex)?.lowerBound,
          iconStartIndex < iconEndIndex else {
      throw HelloError("href of rel component \(rel) not found")
    }
    let faviconURL = String(iconLine[iconStartIndex..<iconEndIndex]).removingHTMLEntities
    if faviconURL.hasPrefix("//") {
      return HelloURLScheme.https.scheme + ":" + faviconURL
    } else if faviconURL.hasPrefix("/") {
      var helloURL = helloURL
      helloURL.path = faviconURL
      return helloURL.string
    } else {
      return faviconURL
    }
  }
}

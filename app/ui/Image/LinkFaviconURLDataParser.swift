import Foundation

import HelloCore
import HelloApp

public actor LinkFaviconURLDataParser {
  
  enum LinkPreviewDataParserError: Error {
    case invalidURL
    case fetchError
    case previewDataNotFound
    case alreadyInProgress
    case failedToPrase
  }
  
  public static let main = LinkFaviconURLDataParser()
  
  var inProgress: Set<String> = []
  
  func getFavicon(for helloURL: HelloURL) async throws -> Data {
    var helloURL = helloURL
    helloURL.scheme = .https
    guard !inProgress.contains(helloURL.root.string) else { throw LinkPreviewDataParserError.alreadyInProgress }
    inProgress.insert(helloURL.root.string)
    defer { inProgress.remove(helloURL.root.string) }
    
    let html: String?
    do {
      let pageData = try await Downloader.main.download(from: helloURL.root.string)
      html = try String(data: pageData, encoding: .utf8)
    } catch {
      Log.error(error.localizedDescription)
      html = nil
    }
    
    if let html {
      do {
        let imageURL = try parse(rel: "apple-touch-icon", from: html, url: helloURL)
        return try await HelloImageDownloadManager.main.download(from: imageURL)
      } catch {
        Log.error(error.localizedDescription)
      }
      
      do {
        let imageURL = try parse(rel: "apple-touch-icon-precomposed", from: html, url: helloURL)
        return try await HelloImageDownloadManager.main.download(from: imageURL)
      } catch {
        Log.error(error.localizedDescription)
      }
    }
    
    helloURL.path = "/apple-touch-icon.png"
    if let imageData = try? await HelloImageDownloadManager.main.download(from: helloURL.string),
       let _ = NativeImage(data: imageData) {
      return imageData
    }
    
    helloURL.path = "/apple-touch-icon-precomposed.png"
    if let imageData = try? await HelloImageDownloadManager.main.download(from: helloURL.string),
       let _ = NativeImage(data: imageData) {
      return imageData
    }
    
    if let html {
      do {
        let imageURL = try parse(rel: "shortcut icon", from: html, url: helloURL)
        return try await HelloImageDownloadManager.main.download(from: imageURL)
      } catch {
        Log.error(error.localizedDescription)
      }
      
      do {
        let imageURL = try parse(rel: "icon", from: html, url: helloURL)
        return try await HelloImageDownloadManager.main.download(from: imageURL)
      } catch {
        Log.error(error.localizedDescription)
      }
    }
    
    helloURL.path = "/favicon.ico"
    if let imageData = try? await HelloImageDownloadManager.main.download(from: helloURL.string) {
      return imageData
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
    
    guard let iconSectionStartIndex = head.range(of: #"rel="\#(rel)""#)?.upperBound,
          let iconSectionEndIndex = head.range(of: ">", range: iconSectionStartIndex..<head.endIndex)?.lowerBound else {
      throw HelloError("requested rel component not found")
    }
    
    let iconLine = head[iconSectionStartIndex..<iconSectionEndIndex]
    
    guard let iconStartIndex = iconLine.range(of: "href=\"")?.upperBound,
          let iconEndIndex = iconLine.range(of: "\"", range: iconStartIndex..<iconLine.endIndex)?.lowerBound,
          iconStartIndex < iconEndIndex else {
      throw HelloError("href component of rel not found")
    }
    let faviconURL = String(iconLine[iconStartIndex..<iconEndIndex]).removingHTMLEntities
    if faviconURL.hasPrefix("/") {
      var helloURL = helloURL
      helloURL.path = faviconURL
      return helloURL.string
    } else {
      return faviconURL
    }
  }
}

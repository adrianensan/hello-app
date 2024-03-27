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
    
    if let pageData = try? await Downloader.main.download(from: helloURL.root.string),
       let html = String(data: pageData, encoding: .utf8),
       let imageURL =
        (try? parse(rel: "apple-touch-icon", from: html, url: helloURL)) ??
        (try? parse(rel: "apple-touch-icon-precomposed", from: html, url: helloURL)) ??
        (try? parse(rel: "shortcut icon", from: html, url: helloURL)) ??
        (try? parse(rel: "icon", from: html, url: helloURL)),
       let imageData = try? await HelloImageDownloadManager.main.download(from: imageURL) {
        return imageData
    }
    
    helloURL.path = "/favicon.ico"
    if let imageData = try? await HelloImageDownloadManager.main.download(from: helloURL.string) {
      return imageData
    }
    
    throw LinkPreviewDataParserError.previewDataNotFound
  }
  
  private func parse(rel: String, from html: String, url helloURL: HelloURL) throws -> String {
    guard let headStartIndex = html.range(of: "<head")?.upperBound,
          let headEndIndex = html.range(of: "</head>")?.lowerBound,
          headStartIndex < headEndIndex else {
      throw LinkPreviewDataParserError.previewDataNotFound
    }
    
    let head = html[headStartIndex..<headEndIndex]
    
    guard let iconSectionStartIndex = head.range(of: #"rel="\#(rel)""#)?.upperBound,
          let iconSectionEndIndex = head.range(of: ">", range: iconSectionStartIndex..<head.endIndex)?.lowerBound else {
      throw LinkPreviewDataParserError.previewDataNotFound
    }
    
    let iconLine = head[iconSectionStartIndex..<iconSectionEndIndex]
    
    guard let iconStartIndex = iconLine.range(of: "href=\"")?.upperBound,
          let iconEndIndex = iconLine.range(of: "\"", range: iconStartIndex..<iconLine.endIndex)?.lowerBound,
          iconStartIndex < iconEndIndex else {
      throw LinkPreviewDataParserError.previewDataNotFound
    }
    let faviconURL = String(iconLine[iconStartIndex..<iconEndIndex]).removingHTMLEntities
    if faviconURL.hasPrefix("/") {
      var helloURL = helloURL
      helloURL.path = faviconURL
      return helloURL.string
    } else {
      return faviconURL
    }
    
    guard let iconSectionStartIndex =
            head.range(of: #"rel="apple-touch-icon""#)?.upperBound ??
            head.range(of: #"rel="apple-touch-icon-precomposed""#)?.upperBound,
          // ??
          //            head.range(of: #"rel="icon""#)?.upperBound ??
            //            head.range(of: #"rel="shortcut icon""#)?.upperBound,
            let iconSectionEndIndex = head.range(of: ">", range: iconSectionStartIndex..<head.endIndex)?.lowerBound else {
      throw LinkPreviewDataParserError.previewDataNotFound
    }
    
    
  }
}

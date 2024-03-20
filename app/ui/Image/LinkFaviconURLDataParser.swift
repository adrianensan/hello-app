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
  
  func getFaviconURL(of url: String) async throws -> String {
    guard !inProgress.contains(url) else { throw LinkPreviewDataParserError.alreadyInProgress }
    inProgress.insert(url)
    defer { inProgress.remove(url) }
    
    let pageData = try await Downloader.main.download(from: url)
    
    guard let html = String(data: pageData, encoding: .utf8) else { throw LinkPreviewDataParserError.previewDataNotFound }
    
    guard let headStartIndex = html.range(of: "<head")?.upperBound,
          let headEndIndex = html.range(of: "</head>")?.lowerBound,
          headStartIndex < headEndIndex else {
      throw LinkPreviewDataParserError.previewDataNotFound
    }
    
    let head = html[headStartIndex..<headEndIndex]

    guard let iconSectionStartIndex = head.range(of: #"rel="icon""#)?.upperBound ?? head.range(of: #"rel="shortcut icon""#)?.upperBound,
          let iconSectionEndIndex = head.range(of: ">", range: iconSectionStartIndex..<head.endIndex)?.lowerBound else {
      throw LinkPreviewDataParserError.previewDataNotFound
    }
    
    let iconLine = head[iconSectionStartIndex..<iconSectionEndIndex]
    
    guard let iconStartIndex = iconLine.range(of: "href=\"")?.upperBound,
          let iconEndIndex = iconLine.range(of: "\"", range: iconStartIndex..<iconLine.endIndex)?.lowerBound,
          iconStartIndex < iconEndIndex else {
      throw LinkPreviewDataParserError.previewDataNotFound
    }
    return String(iconLine[iconStartIndex..<iconEndIndex]).removingHTMLEntities
  }
}

import Foundation

import HelloCore

public extension HTTPResponse<Data?> {
  init(httpURLResponse: HTTPURLResponse, data: Data?) {
    let contentTypeFieldString = httpURLResponse.value(forHTTPHeaderField: "content-type")?.lowercased() ?? ""
    let contentTypeFieldComponents = contentTypeFieldString.components(separatedBy: ";")
    let contentTypeString = contentTypeFieldComponents.first?.trimmingCharacters(in: .whitespacesAndNewlines)
    let contentTypeBoundaryString = contentTypeFieldComponents
      .first { $0.hasPrefix("boundary=") }?
      .deletingPrefix("boundary=")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let contentTypeCharsetString = contentTypeFieldComponents
      .first { $0.hasPrefix("charset=") }?
      .deletingPrefix("charset=")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    self.init(status: .from(code: httpURLResponse.statusCode),
              cache: nil,
              cookies: [],
              customeHeaders: [],
              contentType: .inferFrom(mimeType: contentTypeString ?? ""),
              location: httpURLResponse.value(forHTTPHeaderField: "location"),
              lastModifiedDate: nil,
              body: data)
  }
}

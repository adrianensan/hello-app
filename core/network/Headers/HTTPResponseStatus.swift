public enum HTTPResponseStatus: CustomStringConvertible, Equatable, Sendable {
  case `continue`
  case switchingProtocols
  case ok
  case created
  case accepted
  case nonAuthoritativeInformation
  case noContent
  case resetContent
  case partialContent
  case multipleChoices
  case movedPermanently
  case found
  case seeOther
  case notModified
  case useProxy
  case temporaryRedirect
  case permanentRedirect
  case badRequest
  case unauthorized
  case paymentRequired
  case forbidden
  case notFound
  case methodNotAllowed
  case notAcceptable
  case proxyAuthenticationRequired
  case requestTimeout
  case conflict
  case gone
  case lengthRequired
  case preconditionFailed
  case requestEntityTooLarge
  case requestURITooLong
  case unsupportedMediaType
  case requestedRangeNotSatisfiable
  case expectationFailed
  case imATeapot
  case outdatedClientVersion
  case unprocessableEntity
  case internalServerError
  case notImplemented
  case badGateway
  case serviceUnavailable
  case gatewayTimeout
  case httpVersionNotSupported
  case custom(code: Int, message: String)
  
  public var statusCode: Int {
    switch self {
    case                     .continue: 100
    case           .switchingProtocols: 101
    case                           .ok: 200
    case                      .created: 201
    case                     .accepted: 202
    case  .nonAuthoritativeInformation: 203
    case                    .noContent: 204
    case                 .resetContent: 205
    case               .partialContent: 206
    case              .multipleChoices: 300
    case             .movedPermanently: 301
    case                        .found: 302
    case                     .seeOther: 303
    case                  .notModified: 304
    case                     .useProxy: 305
    case            .temporaryRedirect: 307
    case            .permanentRedirect: 308
    case                   .badRequest: 400
    case                 .unauthorized: 401
    case              .paymentRequired: 402
    case                    .forbidden: 403
    case                     .notFound: 404
    case             .methodNotAllowed: 405
    case                .notAcceptable: 406
    case  .proxyAuthenticationRequired: 407
    case               .requestTimeout: 408
    case                     .conflict: 409
    case                         .gone: 410
    case               .lengthRequired: 411
    case           .preconditionFailed: 412
    case        .requestEntityTooLarge: 413
    case            .requestURITooLong: 414
    case         .unsupportedMediaType: 415
    case .requestedRangeNotSatisfiable: 416
    case            .expectationFailed: 417
    case                    .imATeapot: 418
    case        .outdatedClientVersion: 420
    case          .unprocessableEntity: 422
    case          .internalServerError: 500
    case               .notImplemented: 501
    case                   .badGateway: 502
    case           .serviceUnavailable: 503
    case               .gatewayTimeout: 504
    case      .httpVersionNotSupported: 505
    case          .custom(let code, _): code
    }
  }
  
  public var statusDescription: String {
    switch self {
    case                     .continue: "Continue"
    case           .switchingProtocols: "Switching Protocols"
    case                           .ok: "OK"
    case                      .created: "Created"
    case                     .accepted: "Accepted"
    case  .nonAuthoritativeInformation: "Non-Authoritative Information"
    case                    .noContent: "No Content"
    case                 .resetContent: "Reset Content"
    case               .partialContent: "Partial Content"
    case              .multipleChoices: "Multiple Choices"
    case             .movedPermanently: "Moved Permanently"
    case                        .found: "Found"
    case                     .seeOther: "See Other"
    case                  .notModified: "Not Modified"
    case                     .useProxy: "Use Proxy"
    case            .temporaryRedirect: "Temporary Redirect"
    case            .permanentRedirect: "Permanent Redirect"
    case                   .badRequest: "Bad Request"
    case                 .unauthorized: "Unauthorized"
    case              .paymentRequired: "Payment Required"
    case                    .forbidden: "Forbidden"
    case                     .notFound: "Not Found"
    case             .methodNotAllowed: "Method Not Allowed"
    case                .notAcceptable: "Not Acceptable"
    case  .proxyAuthenticationRequired: "Proxy Authentication Required"
    case               .requestTimeout: "Request Timeout"
    case                     .conflict: "Conflict"
    case                         .gone: "Gone"
    case               .lengthRequired: "Length Required"
    case           .preconditionFailed: "Precondition Failed"
    case        .requestEntityTooLarge: "Request Entity Too Large"
    case            .requestURITooLong: "Request-URI Too Long"
    case         .unsupportedMediaType: "Unsupported Media Type"
    case .requestedRangeNotSatisfiable: "Requested Range Not Satisfiable"
    case            .expectationFailed: "Expectation Failed"
    case                    .imATeapot: "I'm a teapot"
    case        .outdatedClientVersion: "Outdated Client Version"
    case          .unprocessableEntity: "Unprocessable Entity"
    case          .internalServerError: "Internal Server Error"
    case               .notImplemented: "Not Implemented"
    case                   .badGateway: "Bad Gateway"
    case           .serviceUnavailable: "Service Unavailable"
    case               .gatewayTimeout: "Gateway Timeout"
    case      .httpVersionNotSupported: "HTTP Version Not Supported"
    case       .custom(_, let message): message
    }
  }
  
  public static func from(code: String) -> HTTPResponseStatus {
    if let intCode = Int(code) { from(code: intCode) }
    else { .custom(code: 0, message: "Unkown") }
  }
  
  public static func from(code: Int) -> HTTPResponseStatus {
    switch code {
    case 100: .continue
    case 101: .switchingProtocols
    case 200: .ok
    case 201: .created
    case 202: .accepted
    case 203: .nonAuthoritativeInformation
    case 204: .noContent
    case 205: .resetContent
    case 206: .partialContent
    case 300: .multipleChoices
    case 301: .movedPermanently
    case 302: .found
    case 303: .seeOther
    case 304: .notModified
    case 305: .useProxy
    case 307: .temporaryRedirect
    case 308: .permanentRedirect
    case 400: .badRequest
    case 401: .unauthorized
    case 402: .paymentRequired
    case 403: .forbidden
    case 404: .notFound
    case 405: .methodNotAllowed
    case 406: .notAcceptable
    case 407: .proxyAuthenticationRequired
    case 408: .requestTimeout
    case 409: .conflict
    case 410: .gone
    case 411: .lengthRequired
    case 412: .preconditionFailed
    case 413: .requestEntityTooLarge
    case 414: .requestURITooLong
    case 415: .unsupportedMediaType
    case 416: .requestedRangeNotSatisfiable
    case 417: .expectationFailed
    case 418: .imATeapot
    case 420: .outdatedClientVersion
    case 422: .unprocessableEntity
    case 500: .internalServerError
    case 501: .notImplemented
    case 502: .badGateway
    case 503: .serviceUnavailable
    case 504: .gatewayTimeout
    case 505: .httpVersionNotSupported
     default: .custom(code: code, message: "Unkown")
    }
  }
  
  public var isSuccess: Bool {
    statusCode < 400
  }
  
  public var description: String { "\(statusCode) \(statusDescription)" }
}

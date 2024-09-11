import Foundation

public enum ContentTypeCategory: String, Equatable, Codable, Sendable {
  case image
  case audio
  case video
  case text
  case font
  case terminalScript
  case model3D
  case code
  case other
}

public enum ContentType: String, CaseIterable, Equatable, Codable, Sendable {
  
  case none
  
  case plain
  
  case html, css, javascript
  
  case mp3, m4a
  
  case mp4, mov
  
  case heic, heif
  
  case fbx
  
  case directory
  case macosApp
  
  case csv
  case ics
  case otf
  case ttf
  case woff
  case woff2
  case png
  case jpeg
  case tiff
  case gif
  case webpImage
  case svg
  case icon
  case aac
  case oggAudio
  case webmAudio
  case wav
  case midi
  case x3GPP
  case x3GPP2
  case avi
  case mpeg
  case oggVideo
  case webmVideo
  case json
  case xhtml
  case xml
  case xul
  case pdf
  case rtf
  case oldWord
  case oldPowerpoint
  case oldExcel
  case word
  case powerpoint
  case excel
  case epub
  case sh
  case typescript
  case es
  case eot
  case zip
  case tar
  case rar
  case bz
  case bz2
  case x7zip
  case jar
  case ogg
  case bin
  case swift
  case other
  case formData
  case custom
  
  public var category: ContentTypeCategory {
    switch self {
    case .zip, .rar, .tar, .bz, .bz2, .x7zip: .text
    case .png, .jpeg, .heic, .heif, .tiff, .gif, .svg: .image
    case .mp3, .m4a, .wav, .aac, .oggAudio, .webmAudio: .audio
    case .ttf, .otf, .eot: .font
    case .mp4, .mov, .avi, .oggVideo, .webmVideo: .video
    case .plain: .text
    case .pdf, .word, .oldWord: .text
    case .excel, .oldExcel, .csv: .text
    case .json: .code
    case .xml, .html: .code
    case .bin: .other
    case .midi: .other
    case .swift: .code
    case .epub: .other
    case .ics: .other
    default: .other
    }
  }
  
  public var typeString: String {
    switch self {
    case          .none: ""
    case     .directory: "application/x-directory"
    case      .macosApp: "application/macos-app"
    case         .plain: "text/plain"
    case          .html: "text/html"
    case           .css: "text/css"
    case           .csv: "text/cvs"
    case    .javascript: "text/javascript"
    case           .ics: "text/calendar"
    case           .otf: "font/otf"
    case           .ttf: "font/ttf"
    case          .woff: "font/woff"
    case         .woff2: "font/woff2"
    case           .png: "image/png"
    case          .jpeg: "image/jpeg"
    case          .tiff: "image/tiff"
    case           .gif: "image/gif"
    case          .heic: "image/heic"
    case          .heif: "image/heif"
    case     .webpImage: "image/webp"
    case           .svg: "image/svg+xml"
    case          .icon: "image/x-icon"
    case           .aac: "audio/aac"
    case           .mp3: "audio/mpeg"
    case           .m4a: "audio/m4a"
    case           .mp4: "video/mp4"
    case           .mov: "video/quicktime"
    case      .oggAudio: "audio/ogg"
    case     .webmAudio: "audio/webm"
    case           .wav: "audio/wav"
    case          .midi: "audio/midi"
    case         .x3GPP: "video/3gpp"
    case        .x3GPP2: "video/3gpp2"
    case           .avi: "video/x-msvideo"
    case          .mpeg: "video/mpeg"
    case      .oggVideo: "video/ogg"
    case     .webmVideo: "video/webm"
    case          .json: "application/json"
    case         .xhtml: "application/xhtml+xml"
    case           .xml: "application/xml"
    case           .xul: "application/vnd.mozilla.xul+xml"
    case           .pdf: "application/pdf"
    case           .rtf: "application/rtf"
    case       .oldWord: "application/msword"
    case .oldPowerpoint: "application/vnd.ms-powerpoint"
    case      .oldExcel: "application/vnd.ms-excel"
    case          .word: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case    .powerpoint: "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    case         .excel: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case          .epub: "application/epub+zip"
    case            .sh: "application/x-sh"
    case         .swift: "application/swift"
    case    .typescript: "application/typescript"
    case            .es: "application/ecmascript"
    case           .eot: "application/vnd.ms-fontobject"
    case           .zip: "application/zip"
    case           .tar: "application/x-tar"
    case           .rar: "application/x-rar-compressed"
    case            .bz: "application/x-bzip"
    case           .bz2: "application/x-bzip2"
    case         .x7zip: "application/x-7z-compressed"
    case           .jar: "application/java-archive"
    case           .ogg: "application/ogg"
    case      .formData: "multipart/form-data"
    case   .bin, .other: "application/octet-stream"
      
      
    case .fbx: "application/fbx"
    case .custom: "application/octet-stream"
    }
  }
  
  public static func inferFrom(mimeType: String) -> ContentType {
    let mimeType = mimeType.lowercased()
    for type in ContentType.allCases {
      if type.typeString == mimeType { return type }
    }
    return .custom
  }
  
  public static func inferFrom(fileExtension: String) -> ContentType {
    switch fileExtension {
    case            "": .none
    case         "txt": .plain
    case "html", "htm": .html
    case         "css": .css
    case         "csv": .csv
    case          "js": .javascript
    case         "ics": .ics
    case         "otf": .otf
    case         "ttf": .ttf
    case         "fbx": .fbx
    case        "woff": .woff
    case       "woff2": .woff2
    case         "png": .png
    case "jpeg", "jpg": .jpeg
    case "tiff", "tif": .tiff
    case         "gif": .gif
    case        "heic": .heic
    case        "heif": .heif
    case        "webp": .webpImage
    case         "svg": .svg
    case         "ico": .icon
    case         "mp3": .mp3
    case         "m4a": .m4a
    case         "aac": .aac
    case         "oga": .oggAudio
    case        "weba": .webmAudio
    case "midi", "mid": .midi
    case         "3gp": .x3GPP
    case         "3g2": .x3GPP2
    case         "avi": .avi
    case         "mp4": .mp4
    case         "mov": .mov
    case        "mpeg": .mpeg
    case         "ogv": .oggVideo
    case        "webm": .webmVideo
    case         "wav": .wav
    case        "json": .json
    case       "xhtml": .xhtml
    case "xml", "plist": .xml
    case         "xul": .xul
    case         "pdf": .pdf
    case         "rtf": .rtf
    case         "doc": .oldWord
    case         "ppt": .oldPowerpoint
    case         "xls": .oldExcel
    case        "docx": .word
    case        "pptx": .powerpoint
    case        "xlsx": .excel
    case        "epub": .epub
    case          "sh": .sh
    case          "ts": .typescript
    case          "es": .es
    case         "eot": .eot
    case         "zip": .zip
    case         "tar": .tar
    case         "rar": .rar
    case          "bz": .bz
    case         "bz2": .bz2
    case         "jar": .jar
    case          "7z": .x7zip
    case         "ogg": .ogg
    case         "bin": .bin
    case       "swift": .swift
               default: .other
    }
  }
  
  public var iconName: String {
    switch category {
    case .image: "photo"
    case .audio: "music.note"
    case .video: "play.rectangle"
    case .font: "textformat"
    default:
      switch self {
      case .zip, .rar, .tar, .bz, .bz2, .x7zip: "doc.zipper"
      case .plain: "doc.text"
      case .pdf, .word, .oldWord: "doc.richtext"
      case .excel, .oldExcel, .csv: "tablecells"
      case .json: "curlybraces"
      case .xml, .html: "chevron.left.forwardslash.chevron.right"
      case .bin: "terminal"
      case .midi: "pianokeys"
      case .fbx: "move.3d"
      case .swift: "swift"
      case .epub: "book"
      case .ics: "calendar"
      case .directory: "folder"
      case .macosApp: "app"
      default: "doc"
      }
    }
  }
  
  public var description: String { Header.contentTypePrefix + typeString }
}

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
    case .zip, .rar, .tar, .bz, .bz2, .x7zip: return .text
    case .png, .jpeg, .heic, .heif, .tiff, .gif, .svg: return .image
    case .mp3, .m4a, .wav, .aac, .oggAudio, .webmAudio, .oggAudio: return .audio
    case .ttf, .otf, .eot: return .font
    case .mp4, .mov, .avi, .oggVideo, .webmVideo: return .video
    case .plain: return .text
    case .pdf, .word, .oldWord: return .text
    case .excel, .oldExcel, .csv: return .text
    case .json: return .code
    case .xml, .html: return .code
    case .bin: return .other
    case .midi: return .other
    case .swift: return .code
    case .epub: return .other
    case .ics: return .other
    default: return .other
    }
  }
  
  public var typeString: String {
    switch self {
    case          .none: return ""
    case     .directory: return "application/x-directory"
    case      .macosApp: return "application/macos-app"
    case         .plain: return "text/plain"
    case          .html: return "text/html"
    case           .css: return "text/css"
    case           .csv: return "text/cvs"
    case    .javascript: return "text/javascript"
    case           .ics: return "text/calendar"
    case           .otf: return "font/otf"
    case           .ttf: return "font/ttf"
    case          .woff: return "font/woff"
    case         .woff2: return "font/woff2"
    case           .png: return "image/png"
    case          .jpeg: return "image/jpeg"
    case          .tiff: return "image/tiff"
    case           .gif: return "image/gif"
    case          .heic: return "image/heic"
    case          .heif: return "image/heif"
    case     .webpImage: return "image/webp"
    case           .svg: return "image/svg+xml"
    case          .icon: return "image/x-icon"
    case           .aac: return "audio/aac"
    case           .mp3: return "audio/mpeg"
    case           .m4a: return "audio/m4a"
    case           .mp4: return "video/mp4"
    case           .mov: return "video/quicktime"
    case      .oggAudio: return "audio/ogg"
    case     .webmAudio: return "audio/webm"
    case           .wav: return "audio/wav"
    case          .midi: return "audio/midi"
    case         .x3GPP: return "video/3gpp"
    case        .x3GPP2: return "video/3gpp2"
    case           .avi: return "video/x-msvideo"
    case          .mpeg: return "video/mpeg"
    case      .oggVideo: return "video/ogg"
    case     .webmVideo: return "video/webm"
    case          .json: return "application/json"
    case         .xhtml: return "application/xhtml+xml"
    case           .xml: return "application/xml"
    case           .xul: return "application/vnd.mozilla.xul+xml"
    case           .pdf: return "application/pdf"
    case           .rtf: return "application/rtf"
    case       .oldWord: return "application/msword"
    case .oldPowerpoint: return "application/vnd.ms-powerpoint"
    case      .oldExcel: return "application/vnd.ms-excel"
    case          .word: return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case    .powerpoint: return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    case         .excel: return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case          .epub: return "application/epub+zip"
    case            .sh: return "application/x-sh"
    case         .swift: return "application/swift"
    case    .typescript: return "application/typescript"
    case            .es: return "application/ecmascript"
    case           .eot: return "application/vnd.ms-fontobject"
    case           .zip: return "application/zip"
    case           .tar: return "application/x-tar"
    case           .rar: return "application/x-rar-compressed"
    case            .bz: return "application/x-bzip"
    case           .bz2: return "application/x-bzip2"
    case         .x7zip: return "application/x-7z-compressed"
    case           .jar: return "application/java-archive"
    case           .ogg: return "application/ogg"
    case      .formData: return "multipart/form-data"
    case   .bin, .other: return "application/octet-stream"
      
      
    case .fbx: return "application/fbx"
    case .custom: return "application/octet-stream"
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
    case            "": return .none
    case         "txt": return .plain
    case "html", "htm": return .html
    case         "css": return .css
    case         "csv": return .csv
    case          "js": return .javascript
    case         "ics": return .ics
    case         "otf": return .otf
    case         "ttf": return .ttf
    case         "fbx": return .fbx
    case        "woff": return .woff
    case       "woff2": return .woff2
    case         "png": return .png
    case "jpeg", "jpg": return .jpeg
    case "tiff", "tif": return .tiff
    case         "gif": return .gif
    case        "heic": return .heic
    case        "heif": return .heif
    case        "webp": return .webpImage
    case         "svg": return .svg
    case         "ico": return .icon
    case         "mp3": return .mp3
    case         "m4a": return .m4a
    case         "aac": return .aac
    case         "oga": return .oggAudio
    case        "weba": return .webmAudio
    case "midi", "mid": return .midi
    case         "3gp": return .x3GPP
    case         "3g2": return .x3GPP2
    case         "avi": return .avi
    case         "mp4": return .mp4
    case         "mov": return .mov
    case        "mpeg": return .mpeg
    case         "ogv": return .oggVideo
    case        "webm": return .webmVideo
    case         "wav": return .wav
    case        "json": return .json
    case       "xhtml": return .xhtml
    case "xml", "plist": return .xml
    case         "xul": return .xul
    case         "pdf": return .pdf
    case         "rtf": return .rtf
    case         "doc": return .oldWord
    case         "ppt": return .oldPowerpoint
    case         "xls": return .oldExcel
    case        "docx": return .word
    case        "pptx": return .powerpoint
    case        "xlsx": return .excel
    case        "epub": return .epub
    case          "sh": return .sh
    case          "ts": return .typescript
    case          "es": return .es
    case         "eot": return .eot
    case         "zip": return .zip
    case         "tar": return .tar
    case         "rar": return .rar
    case          "bz": return .bz
    case         "bz2": return .bz2
    case         "jar": return .jar
    case          "7z": return .x7zip
    case         "ogg": return .ogg
    case         "bin": return .bin
    case       "swift": return .swift
               default: return .other
    }
  }
  
  public var iconName: String {
    switch self {
    case .zip, .rar, .tar, .bz, .bz2, .x7zip: return "doc.zipper"
    case .png, .jpeg, .heic, .heif, .tiff, .gif, .svg: return "photo"
    case .mp3, .m4a, .wav, .aac, .oggAudio, .webmAudio, .oggAudio: return "music.note"
    case .ttf, .otf, .eot: return "textformat"
    case .mp4, .mov, .avi, .oggVideo, .webmVideo: return "play.rectangle"
    case .plain: return "doc.text"
    case .pdf, .word, .oldWord: return "doc.richtext"
    case .excel, .oldExcel, .csv: return "tablecells"
    case .json: return "curlybraces"
    case .xml, .html: return "chevron.left.forwardslash.chevron.right"
    case .bin: return "terminal"
    case .midi: return "pianokeys"
    case .fbx: return "move.3d"
    case .swift: return "swift"
    case .epub: return "book"
    case .ics: return "calendar"
    case .directory: return "folder"
    case .macosApp: return "app"
    default: return "doc"
    }
  }
  
  public var description: String { Header.contentTypePrefix + typeString }
}

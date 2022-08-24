import Foundation

enum AppiconsetContentsGenerator {
  
  static func contentsFile(for appIconName: String, with scales: [IconScale]) -> String {
    var file = AppiconsetContentsGenerator.contentsJsonFilePrefix
    for scale in scales {
      file += AppiconsetContentsGenerator.contentsJsonEntry(appIconName: appIconName,
                                                            scale: scale,
                                                            isLast: scale == scales.last)
    }
    file += AppiconsetContentsGenerator.contentsJsonFileSuffix
    return file
  }
  
  static func sizeString(for size: Double) -> String {
    size.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", size) : "\(size)"
  }
  
  static func fileName(appIconName: String, scale: IconScale) -> String {
    "\(appIconName)-\(sizeString(for: scale.size.width))x\(sizeString(for: scale.size.height))@\(scale.scaleFactor)x.png"
  }
  
  static func contentsJsonEntry(appIconName: String, scale: IconScale, isLast: Bool) -> String {
    var entry = """
    {
      "filename" : "\(fileName(appIconName: appIconName, scale: scale))",
      "idiom" : "\(scale.purpose.rawValue)",
      "scale" : "\(scale.scaleFactor)x",
    
    """
    
    if let role = scale.role {
      entry += #"  "role" : "\#(role.rawValue)",\#n"#
    }
    
    if let platform = scale.platform {
      entry += #"  "platform" : "\#(platform.rawValue)",\#n"#
    }
    
    if let subtype = scale.subtype {
      entry += #"  "subtype" : "\#(subtype.rawValue)",\#n"#
    }
    
    entry += """
      "size" : "\(sizeString(for: scale.size.width))x\(sizeString(for: scale.size.height))"
    }\(isLast ? "" : ", ")
    """
    
    return entry
  }
  
  static var contentsJsonFilePrefix: String {
    """
    {"images" : [
    """
  }
  
  static var contentsJsonFileSuffix: String {
    """
    ],
    "info" : {
      "author" : "xcode",
      "version" : 1
    }}
    """
  }
}

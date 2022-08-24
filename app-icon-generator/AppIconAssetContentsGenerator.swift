import Foundation

enum AppIconAssetContentsGenerator {
  
  static func contentsFile(for appIconName: String, with scales: [IconScale]) -> String {
    var file = AppIconAssetContentsGenerator.contentsJsonFilePrefix
    for scale in scales {
      file += AppIconAssetContentsGenerator.contentsJsonEntry(appIconName: appIconName,
                                                              scale: scale,
                                                              isLast: scale == scales.last)
    }
    file += AppIconAssetContentsGenerator.contentsJsonFileSuffix
    return file
  }
  
  static func sizeString(for size: Double) -> String {
    size.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", size) : "\(size)"
  }
  
  static func fileName(appIconName: String, scale: IconScale) -> String {
    "\(appIconName)-\(sizeString(for: scale.size.width))x\(sizeString(for: scale.size.height))@\(scale.scaleFactor)x.png"
  }
  
  static func contentsJsonEntry(appIconName: String, scale: IconScale, isLast: Bool) -> String {
    """
    {
      "filename" : "\(fileName(appIconName: appIconName, scale: scale))",
      "idiom" : "universal",
      "scale" : "\(scale.scaleFactor)x"
    }\(isLast ? "" : ",")
    """
  }
  
  static var contentsJsonFilePrefix: String {
    """
    {
    "images" : [
    {
      "idiom" : "universal",
      "scale" : "1x"
    },
    """
  }
  
  static var contentsJsonFileSuffix: String {
    """
    ],
    "info" : {
      "author" : "xcode",
      "version" : 1
    }
    }
    """
  }
}

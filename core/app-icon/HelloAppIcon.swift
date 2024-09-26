import Foundation

public struct HelloAppIconCollection: Identifiable, Sendable {
  
  public enum AppIconCollectionLayout: Equatable, Sendable {
    case grid
    case gridWithLabels
    case list
    
    public var showLabel: Bool {
      switch self {
      case .grid: false
      case .gridWithLabels: true
      case .list: true
      }
    }
  }
  
  public var id: String
  public var name: String?
  public var icons: [any HelloAppIcon]
  public var layout: AppIconCollectionLayout
  
  public init(id: String = .uuid,
              name: String? = nil,
              icons: [any HelloAppIcon],
              layout: AppIconCollectionLayout) {
    self.id = id
    self.name = name
    self.icons = icons
    self.layout = layout
  }
}

public protocol HelloAppIcon: Codable, Hashable, Identifiable, Sendable {
  var id: String { get }
  
  var name: String { get }
  
  var availability: FeatureAvailability { get }
}

public extension HelloAppIcon {
  var systemName: String {
    "app-icon-\(id)"
  }
}

public enum HelloAppIconTintFill: Codable, Hashable, Sendable {
  case color(HelloColor)
  case gradient(HelloColor, HelloColor)
  case colorBlock([HelloColor], Orientation = .vertical)
  
  static func standardGradient(for color: HelloColor) -> HelloAppIconTintFill {
    .gradient(color.modify(saturation: 0.1, brightness: -0.25), color)
  }
  
  public var color: HelloColor {
    switch self {
    case .color(let color): color
    case .gradient(_, let color): color
    case .colorBlock(let colors, let vertical): colors.first ?? .black
    }
  }
}

public protocol HelloTintableAppIcon: HelloAppIcon {
  
//  static func icon(for tint: HelloAppIconTint) -> Self
  
  init(tint: HelloAppIconTint)
}

public extension HelloTintableAppIcon {
  
}

public struct HelloImageAppIconSource: Sendable {
  public var imageName: String
  public var bundle: Bundle
  
  public init(imageName: String, bundle: Bundle) {
    self.imageName = imageName
    self.bundle = bundle
  }
}

public protocol HelloImageAppIcon: HelloAppIcon {
  var imageSource: HelloImageAppIconSource { get }
}

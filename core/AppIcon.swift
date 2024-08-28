import Foundation

public enum AppIconAvailability: String, Sendable {
  case free
  case paid
  case hidden
  
  public var isAlwaysVisible: Bool {
    switch self {
    case .free: true
    case .paid: true
    case .hidden: false
    }
  }
}

public protocol BaseAppIcon: Codable, Hashable, Identifiable, CaseIterable, Sendable {
  
  init?(rawValue: String)
  
  static var defaultIcon: Self { get }
  
  static var collections: [AppIconCollection<Self>] { get }
  
  var rawValue: String { get }
  
  var displayName: String { get }
  
  var isFree: Bool { get }
  
  var availabilit: AppIconAvailability { get }
}

public extension BaseAppIcon {
  var id: String {
    rawValue
  }
  
  var imageName: String {
    "app-icon-\(rawValue)"
  }
  
  var systemName: String? {
    switch self {
    case Self.defaultIcon: nil
    default: imageName
    }
  }
  
  static var allIcons: [Self] { Array(allCases) }
  
  static func infer(from systemName: String?) -> Self {
    if let systemName = systemName {
      Self(rawValue: systemName.deletingPrefix("app-icon-")) ?? defaultIcon
    } else {
      defaultIcon
    }
  }
}

public struct AppIconCollection<AppIcon: BaseAppIcon>: Identifiable, Sendable {
  
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
  public var icons: [AppIcon]
  public var layout: AppIconCollectionLayout
  
  public init(id: String = .uuid,
              name: String? = nil,
              icons: [AppIcon],
              layout: AppIconCollectionLayout) {
    self.id = id
    self.name = name
    self.icons = icons
    self.layout = layout
  }
}

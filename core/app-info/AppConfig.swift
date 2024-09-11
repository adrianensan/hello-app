import Foundation

public protocol HelloAppConfig {
  associatedtype AppIconType: BaseAppIcon
  
  var id: String { get }
  var name: String { get }
}

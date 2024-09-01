import Foundation

public protocol HelloPickerItem: Hashable, Identifiable, Sendable {
  
  var id: String { get }
  
  var name: String { get }
}

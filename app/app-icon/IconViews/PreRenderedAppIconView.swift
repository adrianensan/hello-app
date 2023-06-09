import SwiftUI

public struct PreRenderedAppIconView: View {
  
  let name: String
  
  public init(name: String) {
    self.name = name
  }
  
  public var body: some View {
    Image("\(name)-prerendered")
      .resizable()
      .aspectRatio(contentMode: .fill)
  }
}

import SwiftUI

public extension View {
  func frame(_ size: CGSize?, alignment: Alignment = .center) -> some View {
    frame(width: size?.width, height: size?.height, alignment: alignment)
  }
  
  func frame(minSize: CGSize, maxSize: CGSize, alignment: Alignment = .center) -> some View {
    frame(minWidth: minSize.width, maxWidth: maxSize.width, minHeight: minSize.height, maxHeight: maxSize.height, alignment: alignment)
  }
  
  func frame(_ size: CGFloat) -> some View {
    frame(width: size, height: size)
  }
}

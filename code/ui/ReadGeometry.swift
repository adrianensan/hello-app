import SwiftUI

public extension View {
  func readGeometry(onChange: @escaping (GeometryProxy) -> Void) -> some View {
    background(GeometryReader { geometry -> Color in
      onChange(geometry)
      return Color.clear
    })
  }
}

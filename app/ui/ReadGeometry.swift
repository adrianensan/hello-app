import SwiftUI

public extension View {
  func readGeometry(onChange: @escaping @MainActor (GeometryProxy) -> Void) -> some View {
    background(GeometryReader { geometry -> Color in
      Task { onChange(geometry) }
      return Color.clear
    })
  }
}

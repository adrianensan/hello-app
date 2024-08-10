import SwiftUI

public extension View {
  func readGeometry(onChange: @escaping @MainActor (GeometryProxy) -> Void) -> some View {
    background(GeometryReader { geometry in
      Task { onChange(geometry) }
      return Color.clear
    })
  }
  
  func readSize(onChange: @escaping @MainActor (CGSize) -> Void) -> some View {
    background(GeometryReader { geometry in
      Task { onChange(geometry.size) }
      return Color.clear
    })
  }
  
  func readFrame(in coordinateSpace: some CoordinateSpaceProtocol = .global, onChange: @escaping @MainActor (CGRect) -> Void) -> some View {
    background(GeometryReader { geometry in
      let frame = geometry.frame(in: coordinateSpace)
      Task { onChange(frame) }
      return Color.clear
    })
  }
}

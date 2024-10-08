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
  
  func readSizeSync(onChange: @escaping @MainActor (CGSize) -> Void) -> some View {
    background(GeometryReader { geometry in
      onChange(geometry.size)
      return Color.clear
    })
  }
  
  func readSize(to binding: Binding<CGSize>, onChange: (@MainActor () -> Void)?) -> some View {
    background(GeometryReader { geometry in
      Task {
        binding.wrappedValue = geometry.size
        onChange?()
      }
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
  
  func readFrame(in coordinateSpace: some CoordinateSpaceProtocol = .global, to binding: Binding<CGRect>) -> some View {
    background(GeometryReader { geometry in
      let frame = geometry.frame(in: coordinateSpace)
      Task { binding.wrappedValue = frame }
      return Color.clear
    })
  }
  
  func readFrame(in coordinateSpace: some CoordinateSpaceProtocol = .global, to binding: Binding<CGRect?>) -> some View {
    background(GeometryReader { geometry in
      let frame = geometry.frame(in: coordinateSpace)
      Task { binding.wrappedValue = frame }
      return Color.clear
    })
  }
  
  func readFrame(in coordinateSpace: some CoordinateSpaceProtocol = .global,
                 to binding: Binding<CGRect>,
                 onChange: (@MainActor () -> Void)?) -> some View {
    background(GeometryReader { geometry in
      let frame = geometry.frame(in: coordinateSpace)
      Task {
        binding.wrappedValue = frame
        onChange?()
      }
      return Color.clear
    })
  }
}

import SwiftUI

public struct PositionReaderView: View {
  
  private var onPositionChange: (CGPoint) -> Void
  private var coordinateSpace: CoordinateSpace = .global
  
  public init(onPositionChange: @escaping (CGPoint) -> Void,
              coordinateSpace: CoordinateSpace = .global) {
    self.onPositionChange = onPositionChange
    self.coordinateSpace = coordinateSpace
  }
  
  public var body: some View {
    Color.clear
      .frame(height: 0)
      .readGeometry { onPositionChange($0.frame(in: coordinateSpace).origin) }
  }
}

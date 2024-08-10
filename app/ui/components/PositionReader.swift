import SwiftUI

public struct PositionReaderView<CoordinateSpace: CoordinateSpaceProtocol>: View {
  
  private var onPositionChange: (CGPoint) -> Void
  private var coordinateSpace: CoordinateSpace
  
  public init(onPositionChange: @escaping (CGPoint) -> Void,
              coordinateSpace: CoordinateSpace = .global) {
    self.onPositionChange = onPositionChange
    self.coordinateSpace = coordinateSpace
  }
  
  public var body: some View {
    Color.clear
      .frame(height: 0)
      .readFrame(in: coordinateSpace) { onPositionChange($0.origin) }
  }
}

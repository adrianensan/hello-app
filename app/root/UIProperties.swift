import SwiftUI

#if os(iOS) || os(watchOS)
public typealias NativeEdgeInsets = UIEdgeInsets
#elseif os(macOS)
public typealias NativeEdgeInsets = NSEdgeInsets
#endif


public extension EdgeInsets {
  init(_ nativeInsets: NativeEdgeInsets) {
    self.init(top: nativeInsets.top, leading: nativeInsets.left, bottom: nativeInsets.bottom, trailing: nativeInsets.right)
  }
}

@MainActor
public class UIProperties: ObservableObject {
  
  @Published public var size: CGSize
  @Published public var safeAreaInsets: EdgeInsets
  
  public var extraSafeArea: CGFloat = 0
  
  public init(initialSize: CGSize? = nil, initialSafeArea: NativeEdgeInsets? = nil) {
    size = initialSize ?? .zero
    safeAreaInsets = EdgeInsets(initialSafeArea ?? NativeEdgeInsets())
  }
  
  public func updateSize(to size: CGSize) {
    guard self.size != size else { return }
    self.size = size
  }
  
  public func updateSafeAreaInsets(to nsEdgeInsets: NativeEdgeInsets) {
    var edgeInsets = EdgeInsets(nsEdgeInsets)
    edgeInsets.top += extraSafeArea
    guard safeAreaInsets != edgeInsets else { return }
    safeAreaInsets = edgeInsets
  }
}

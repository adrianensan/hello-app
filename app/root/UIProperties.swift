import SwiftUI
import Combine

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
  @Published public var scaleFactor: CGFloat = 1
  #if os(iOS)
  @Published public var keyboardFrame: CGRect = .zero
  var keyboardAnimationDuration: CGFloat = 0
  
  public var isKeyboardShowing: Bool { keyboardFrame.height > 0 }
  #endif
  
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
  
  #if os(iOS)
  public func updateKeyboardFrame(to keyboardFrame: CGRect) {
    guard self.keyboardFrame != keyboardFrame else { return }
    withAnimation(.easeOut(duration: keyboardAnimationDuration)) {
      self.keyboardFrame = keyboardFrame
    }
  }
  #endif
}

import SwiftUI
import Combine

#if os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
public typealias NativeEdgeInsets = UIEdgeInsets
#elseif os(macOS)
public typealias NativeEdgeInsets = NSEdgeInsets
#endif


public extension EdgeInsets {
  init(_ nativeInsets: NativeEdgeInsets) {
    self.init(top: nativeInsets.top, leading: nativeInsets.left, bottom: nativeInsets.bottom, trailing: nativeInsets.right)
  }
}

//@available(iOS 17.0, *)
//@available(macOS 14.0, *)
//@MainActor
//@Observable
//public class HelloSafeArea: ObservableObject {
//  public var safeAreaInsets: EdgeInsets = .init()
//  
//  #if os(iOS)
//  public var keyboardFrame: CGRect = .zero
//  #endif
//  
//  public func updateSafeAreaInsets(to edgeInsets: EdgeInsets) {
//    guard safeAreaInsets != edgeInsets else { return }
//    safeAreaInsets = edgeInsets
//  }
//  
//  #if os(iOS)
//  public func updateKeyboardFrame(to keyboardFrame: CGRect) {
//    guard self.keyboardFrame != keyboardFrame else { return }
//    self.keyboardFrame = keyboardFrame
//  }
//  #endif
//}

@MainActor
@Observable
public class UIProperties {
  
  public var size: CGSize
  public var safeAreaInsets: EdgeInsets
  public var scaleFactor: CGFloat = 1
  #if os(iOS)
  public var keyboardFrame: CGRect = .zero
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
  
  public var horizontalMargin: CGFloat { 6 + max(0, min(36, (size.width - 320) / 5)) }
  
  public var innerHorizontalMargin: CGFloat { 8 + max(0, min(8, (size.width - 320) / 5)) }
  
  #if os(iOS)
  public func updateKeyboardFrame(to keyboardFrame: CGRect) {
    guard self.keyboardFrame != keyboardFrame else { return }
    withAnimation(.easeOut(duration: keyboardAnimationDuration)) {
      self.keyboardFrame = keyboardFrame
    }
  }
  #endif
}

#if os(watchOS)
import SwiftUI

import HelloCore

public struct HelloWatchRootView<Content: View>: View {
  
  private let view: Content
  
  @State private var windowFrame: CGRect = .zero
  @State private var safeArea: EdgeInsets = EdgeInsets()
  
  public init(@ViewBuilder _ content: () -> Content) {
    self.view = content()
  }
  
  public var body: some View {
    view
      .ignoresSafeArea()
      .environment(\.windowFrame, windowFrame)
      .environment(\.viewFrame, windowFrame)
      .environment(\.safeArea, safeArea)
      .readGeometry {
        windowFrame = $0.frame(in: .global)
        safeArea = $0.safeAreaInsets
//        UIConstantsObservable.main.safeAreaInsets.top = WKExtension.shared().rootInterfaceController?.systemMinimumLayoutMargins.top ?? 0
      }
  }
}
#endif

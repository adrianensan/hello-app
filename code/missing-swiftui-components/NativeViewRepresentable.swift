import SwiftUI

#if os(iOS)
struct NativeViewRepresentable: UIViewRepresentable {
  
}
#elseif os(macOS)
protocol NativeViewRepresentable: NSViewRepresentable {
  func makeView(context: Context) -> NSViewType
  static func dismantleView(_ nsView: NSViewType, coordinator: Coordinator)
  func updateView(_ nsView: NSViewType, context: Context)
}

extension NativeViewRepresentable {
  public func makeNSView(context: Context) -> NSViewType {
    makeView(context: context)
  }
  
  public static func dismantleNSView(_ nsView: NSViewType, coordinator: Coordinator) {
    dismantleView(nsView, coordinator: coordinator)
  }
  
  public func updateNSView(_ nsView: NSViewType, context: Context) {
    updateView(nsView, context: context)
  }
}

#endif

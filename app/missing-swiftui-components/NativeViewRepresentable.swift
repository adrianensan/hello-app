import SwiftUI

#if os(iOS)
protocol NativeViewRepresentable: UIViewRepresentable {
  func makeView(context: Context) -> UIViewType
  static func dismantleView(_ uiView: UIViewType, coordinator: Coordinator)
  func updateView(_ uiView: UIViewType, context: Context)
}

extension NativeViewRepresentable {
  public func makeUIView(context: Context) -> UIViewType {
    makeView(context: context)
  }
  
  public static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator) {
    dismantleView(uiView, coordinator: coordinator)
  }
  
  public func updateUIView(_ uiView: UIViewType, context: Context) {
    updateView(uiView, context: context)
  }
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

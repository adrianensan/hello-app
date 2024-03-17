import SwiftUI

import HelloCore

public struct HelloAppIconView: Sendable {
  public var layers: [AnyView]
  
  public init(front: some View,
              middle: some View,
              back: some View) {
    layers = [
      AnyView(front),
      AnyView(middle),
      AnyView(back)
    ]
  }
  
  public init(front: some View,
              back: some View) {
    layers = [
      AnyView(front),
      AnyView(back)
    ]
  }
  
  public init(view: some View) {
    layers = [AnyView(view)]
  }
  
  public var flattenedView: some View {
    ZStack {
      ForEach(0..<layers.count) { i in
        layers[layers.count - 1 - i]
      }
    }
  }
}

public enum MacAppIconView: Sendable {
  case preMasked(HelloAppIconView)
  case unmasked(HelloAppIconView)
  
  public var view: HelloAppIconView {
    switch self {
    case .preMasked(let anyView):
      anyView
    case .unmasked(let anyView):
      HelloAppIconView(view: MacAppIconWrapperView(anyView.flattenedView))
    }
  }
}

public protocol AnyAppIconView: BaseAppIcon {
  var view: HelloAppIconView { get }
  
  var delayBeforeCapture: TimeInterval { get }
}

public extension AnyAppIconView {
  var view: HelloAppIconView {
    if let iosAppIcon = self as? any IOSAppIcon {
      return iosAppIcon.iOSView
    } else if let macAppIcon = self as? any MacOSAppIcon {
      return macAppIcon.macOSView.view
    } else {
      return HelloAppIconView(view: Color.clear)
    }
  }
  
  var delayBeforeCapture: TimeInterval { 0 }
}

public protocol IOSAppIcon: AnyAppIconView {
  var iOSView: HelloAppIconView { get }
}

public extension IOSAppIcon {
  var iOSView: HelloAppIconView { view }
}

public protocol MacOSAppIcon: AnyAppIconView {
  var macOSView: MacAppIconView { get }
}

public extension MacOSAppIcon {
  var macOSView: MacAppIconView { .unmasked(view) }
}

public protocol IMessageAppIcon: AnyAppIconView {
  var iMessageView: HelloAppIconView { get }
}

public extension IMessageAppIcon {
  var iMessageView: HelloAppIconView { view }
}

public protocol WatchAppIcon: AnyAppIconView {
  var watchOSView: HelloAppIconView { get }
}

public extension WatchAppIcon {
  var watchOSView: HelloAppIconView { view }
}

public protocol VisionOSAppIcon: AnyAppIconView {
  var visionOSView: HelloAppIconView { get }
}

public extension VisionOSAppIcon {
  var visionOSView: HelloAppIconView { view }
}

public protocol TVOSAppIcon: AnyAppIconView {
  var tvOSView: HelloAppIconView { get }
}

public extension TVOSAppIcon {
  var tvOSView: HelloAppIconView { view }
}

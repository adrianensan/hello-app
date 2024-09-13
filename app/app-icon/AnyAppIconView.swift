import SwiftUI

import HelloCore

@MainActor
public struct HelloIOSAppIconView: Sendable {
  public var light: HelloAppIconView
  public var dark: HelloAppIconView?
  public var tintable: HelloAppIconView?
  
  private init(light: HelloAppIconView,
               dark: HelloAppIconView? = nil,
               tintable: HelloAppIconView? = nil) {
    self.light = light
    self.dark = dark
    self.tintable = tintable
  }
  
  public static func classic(_ icon: HelloAppIconView) -> HelloIOSAppIconView {
    HelloIOSAppIconView(light: icon)
  }
  
  public static func variants(light: HelloAppIconView, dark: HelloAppIconView, tintable: HelloAppIconView) -> HelloIOSAppIconView {
    HelloIOSAppIconView(light: light, dark: dark, tintable: tintable)
  }
  
  public static func auto(icon: some View, accent: HelloColor) -> HelloIOSAppIconView {
    HelloIOSAppIconView(
      light: HelloAppIconView(
        front:
          GeometryReader { geometry in
            icon.foregroundStyle(.white)
              .compositingGroup()
              .shadow(color: .black.opacity(0.2), radius: 0.005 * geometry.size.minSide)
          }
        ,
        back: LinearGradient(
          colors: [accent.modify(saturation: 0.1, brightness: -0.2).swiftuiColor,
                   accent.swiftuiColor],
          startPoint: .top,
          endPoint: .bottom)),
      dark: HelloAppIconView(
        view: icon.foregroundStyle(LinearGradient(
          colors: [accent.modify(saturation: -0.05, brightness: 0.1).swiftuiColor,
                   accent.swiftuiColor,
                   accent.modify(saturation: 0.1, brightness: -0.2).swiftuiColor],
          startPoint: .top,
          endPoint: .bottom)
        )),
      tintable: HelloAppIconView(
        front: icon.foregroundStyle(LinearGradient(
          colors: [.white, Color(white: 0.6)],
          startPoint: .top,
          endPoint: .bottom)),
        back: Color.black))
  }
}

@MainActor
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
  
  public init(_ view: () -> some View) {
    layers = [AnyView(view())]
  }
  
  public var flattenedView: some View {
    ZStack {
      ForEach(0..<layers.count, id: \.self) { i in
        layers[layers.count - 1 - i]
      }
    }
  }
}

@MainActor
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

@MainActor
public protocol AnyAppIconView: BaseAppIcon {
  var view: HelloAppIconView { get }
  
  var delayBeforeCapture: TimeInterval { get }
}

public extension AnyAppIconView {
  var delayBeforeCapture: TimeInterval { 0 }
}

public protocol IOSAppIcon: AnyAppIconView {
  var iOSView: HelloIOSAppIconView { get }
}

public extension IOSAppIcon {
  var iOSView: HelloIOSAppIconView { .classic(view) }
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

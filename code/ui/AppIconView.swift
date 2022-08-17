import SwiftUI

import HelloCore

public enum MacAppIconView {
  case preMasked(AnyView)
  case unmasked(AnyView)
  
  public var view: AnyView {
    switch self {
    case .preMasked(let anyView):
      return anyView
    case .unmasked(let anyView):
      return AnyView(MacAppIconWrapperView(anyView))
    }
  }
}

public protocol AnyAppIconView: BaseAppIcon {
  var view: AnyView { get }
}

public extension AnyAppIconView {
  var view: AnyView {
    if let iosAppIcon = self as? any IOSAppIcon {
      return iosAppIcon.iOSView
    } else if let macAppIcon = self as? any MacAppIcon {
      return macAppIcon.macView.view
    } else {
      return AnyView(Color.clear)
    }
  }
}

public protocol IOSAppIcon: AnyAppIconView {
  var iOSView: AnyView { get }
}

public protocol MacAppIcon: AnyAppIconView {
  var macView: MacAppIconView { get }
}

public protocol IMessageAppIcon: AnyAppIconView {
  var iMessageView: AnyView { get }
}

public protocol WatchAppIcon: AnyAppIconView {
  var watchView: AnyView { get }
}

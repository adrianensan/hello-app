import Foundation

import HelloCore
import HelloApp

extension EyesHelloAppIcon: HelloSwiftUIAppIcon {
  public var baseView: HelloAppIconViewLayers {
    .init { StandardAppIconView(characterView: HelloEyes(), tint: tint) }
  }
}


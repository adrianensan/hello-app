#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct OtherHelloAppsView: View {
  
  var size: CGFloat
  
  public init(size: CGFloat = 40) {
    self.size = size
  }
  
  public var body: some View {
    HStack(spacing: 4) {
      ForEach(KnownApp.all) { knownApp in
        KnownAppIconView(app: knownApp, prefferedPlatform: .iOS)
          .frame(width: size, height: size)
      }
    }
  }
}
#endif

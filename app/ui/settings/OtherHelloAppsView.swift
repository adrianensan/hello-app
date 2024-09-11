#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct OtherHelloAppsView: View {
  
  public init() {}
  
  public var body: some View {
    HStack(spacing: 4) {
      ForEach(KnownApp.all) { knownApp in
        KnownAppIconView(app: knownApp, prefferedPlatform: .iOS)
          .frame(width: 40, height: 40)
          .frame(width: 44, height: 44)
      }
    }
  }
}
#endif

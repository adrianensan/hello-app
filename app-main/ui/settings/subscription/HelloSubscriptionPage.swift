#if os(iOS)
import SwiftUI
import StoreKit

import HelloCore
import HelloApp

public struct HelloSubscriptionPage: View {
  
  public init() {}
  
  public var body: some View {
    NavigationPage(allowScroll: false) {
      HelloSubscriptionPageContent()
    }
  }
}
#endif

#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct HelloAppSheet: View {
  
  var app: KnownApp
  
  var body: some View {
    HelloPager(name: app.name) { HelloAppSheetContent(app: app) }
      .frame(height: 200)
  }
}
#endif

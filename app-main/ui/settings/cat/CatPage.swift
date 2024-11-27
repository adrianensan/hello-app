#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct CatPage: View {
  
  var body: some View {
    HelloPage(title: "Monkey") {
      CatPageContent()
    }
  }
}
#endif

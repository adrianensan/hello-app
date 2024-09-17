#if os(iOS)
import SwiftUI

import HelloCore

struct CatPage: View {
  
  var body: some View {
    NavigationPage(title: "Monkey") {
      CatPageContent()
    }
  }
}
#endif

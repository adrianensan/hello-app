#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct CatPageContent: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeArea
  @Environment(PagerModel.self) private var pagerModel
  
  @Persistent(.deviceID) private var deviceID
  @Persistent(.firstDateLaunched) private var firstDateLaunched
  
  var body: some View {
    VStack(spacing: 24) {
      Text("This is Monkey.")
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(theme.foreground.primary.style)
        .frame(maxWidth: .infinity)
      
      HelloImageView(.asset(bundle: .helloAppMain, named: "cat"), viewable: true, cornerRadius: 16, resizeMode: .fit)
        .frame(width: 300, height: 300)
    }
  }
}
#endif

#if os(iOS)
import SwiftUI

struct HomeBarDimmerView: View {
  
  @Environment(\.isActive) private var isActive
  @Environment(\.theme) private var theme
  
  static var isSupported: Bool {
    Device.current.homeBarWidth > 0
  }
  
  var body: some View {
    if theme.theme.isDim {
      ZStack {
        Capsule()
          .fill(.white.opacity(isActive ? 1 : 0))
          .padding(.horizontal, 1)
        
        Capsule()
          .fill(.white.opacity(isActive ? 1 : 0))
          .padding(.vertical, 1)
      }.frame(width: Device.current.homeBarWidth, height: 5)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
  }
}

public extension View {
  @ViewBuilder
  func dimHomeBarForTheme() -> some View {
    if HomeBarDimmerView.isSupported {
      self.overlay(HomeBarDimmerView())
    } else {
      self
    }
  }
}
#endif

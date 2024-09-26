import SwiftUI

import HelloCore

public struct HelloEyes: View {
  
  var eyeSpacing: CGFloat { 0.33 }
  var eyeWidth: CGFloat { 0.06 }
  var eyeHeight: CGFloat { 0.1 }
  
  public init() {}
  
  public var body: some View {
    GeometryReader { geometry in
      HStack(spacing: 0) {
        RoundedRectangle(cornerRadius: 0.45 * eyeWidth * geometry.size.width, style: .continuous)
          .fill()
          .frame(width: eyeWidth * geometry.size.width)
        Spacer(minLength: 0)
        RoundedRectangle(cornerRadius: 0.45 * eyeWidth * geometry.size.width, style: .continuous)
          .fill()
          .frame(width: eyeWidth * geometry.size.width)
      }.frame(width: eyeSpacing * geometry.size.width, height: eyeHeight * geometry.size.width)
        .offset(y: 0.06 * geometry.size.height)
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
  }
}

import SwiftUI

import HelloCore

public struct OutlineHelloEyes: View {
  
  var eyeSpacing: CGFloat { 0.33 }
  var eyeWidth: CGFloat { 0.06 }
  var eyeHeight: CGFloat { 0.1 }
  
  var outlineWidth: CGFloat
  
  public init(strokeWidth: Double = 0.0125) {
    self.outlineWidth = strokeWidth
  }
  
  public var body: some View {
    GeometryReader { geometry in
      HStack(spacing: 0) {
        RoundedRectangle(cornerRadius: 0.45 * eyeWidth * geometry.size.width, style: .continuous)
          .stroke(lineWidth: outlineWidth * geometry.size.minSide)
          .frame(width: eyeWidth * geometry.size.width)
        Spacer(minLength: 0)
        RoundedRectangle(cornerRadius: 0.45 * eyeWidth * geometry.size.width, style: .continuous)
          .stroke(lineWidth: outlineWidth * geometry.size.minSide)
          .frame(width: eyeWidth * geometry.size.width)
      }.frame(width: eyeSpacing * geometry.size.width, height: eyeHeight * geometry.size.width)
        .offset(y: 0.06 * geometry.size.height)
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
  }
}

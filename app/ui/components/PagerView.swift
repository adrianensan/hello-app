import SwiftUI

import HelloCore

public struct PagerView: View {
  
  @ObservedObject var model: PagerViewModel
  
  @State var viewDepth: CGFloat = 0
  
  public init(model: PagerViewModel) {
    self.model = model
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        HStack(spacing: 0) {
          ForEach(0..<model.viewStack.count, id: \.self) { i in
            model.viewStack[i]
              .frame(width: geometry.size.width, height: geometry.size.height)
              .allowsHitTesting(i == model.viewDepth - 1)
          }
        }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
          .offset(x: -CGFloat(model.viewDepth - 1) * geometry.size.width)
          .animation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.35), value: model.viewDepth)
      }.frame(width: geometry.size.width, height: geometry.size.height)
        .clipShape(Rectangle())
    }.environmentObject(model)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

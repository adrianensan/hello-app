import SwiftUI

public struct RedditIconView: View {
  
  private let characterView: AnyView
  
  public init<CharacterView: View>(characterView: CharacterView) {
    self.characterView = AnyView(characterView)
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        Circle()
          .fill(LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.99, green: 0.49, blue: 0.08, opacity: 1),
                                                           Color(.sRGB, red: 0.93, green: 0.03, blue: 0.12, opacity: 1)]),
                               startPoint: .top, endPoint: .bottom))
          .frame(width: 0.88 * geometry.size.minSide, height: 0.88 * geometry.size.minSide)
        characterView
          .frame(width: 0.75 * geometry.size.minSide, height: 0.75 * geometry.size.minSide)
      }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }.background(.white)
  }
}

import SwiftUI

public struct FacebookBackgroundView: View {
  
  public init() { }
  
  public var body: some View {
    LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.1, green: 0.69, blue: 1, opacity: 1),
                                               Color(.sRGB, red: 0.1, green: 0.38, blue: 0.88, opacity: 1)]),
                   startPoint: .top, endPoint: .bottom)
  }
}

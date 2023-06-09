import SwiftUI

public struct InstagramBackgroundView: View {
  
  public init() { }
  
  public var body: some View {
    GeometryReader { geometry in
      RadialGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.98, green: 0.86, blue: 0.52, opacity: 1),
                                                 Color(.sRGB, red: 0.92, green: 0.52, blue: 0.23, opacity: 1),
                                                 Color(.sRGB, red: 0.77, green: 0.23, blue: 0.46, opacity: 1),
                                                 Color(.sRGB, red: 0.54, green: 0.22, blue: 0.72, opacity: 1),
                                                 Color(.sRGB, red: 0.32, green: 0.36, blue: 0.81, opacity: 1)]),
                     center: .init(x: 0.2, y: 1), startRadius: 0, endRadius: 1.4 * geometry.size.width)
    }
  }
}

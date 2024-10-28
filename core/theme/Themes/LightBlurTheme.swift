import Foundation

public extension HelloTheme {
  
  static var lightBlur: HelloTheme {
    HelloTheme(
      id: "light-blur",
      name: "Light Blur",
      scheme: .light,
      baseLayer: .init(
        background: .blur(dark: false,
                          overlay: HelloColor(r: 1, g: 1, b: 1, a: 0.3),
                          border: .init(color: .black.opacity(0.1)))
      ),
      headerLayer: .init(
        background: .blur(dark: false,
                          overlay: HelloColor(r: 1, g: 1, b: 1, a: 0.2),
                          border: .init(color: .black.opacity(0.1)))
      ),
      floatingLayer: .init(
        background: .blur(dark: false,
                          overlay: HelloColor(r: 1, g: 1, b: 1, a: 0.2),
                          border: .init(color: .black.opacity(0.1)))
      ),
      surfaceLayer: .init(
        background: .color(color: HelloColor(r: 1, g: 1, b: 1, a: 0.2),
                           border: .init(color: .black.opacity(0.1)))
      ),
      surfaceSectionLayer: .init(
        background: .color(color: HelloColor(r: 1, g: 1, b: 1, a: 0.2),
                           border: .init(color: .black.opacity(0.1)))
      )
    )
  }
}

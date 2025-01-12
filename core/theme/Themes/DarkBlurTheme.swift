import Foundation

public extension HelloTheme {
  
  static var darkBlur: HelloTheme {
    HelloTheme(
      id: "dark-blur",
      name: "Dark Blur",
      scheme: .dark,
      baseLayer: .init(
        background: .blur(
          dark: true,
          overlay: HelloColor(r: 0.01, g: 0.01, b: 0.01, a: 0.32),
          border: .init(color: .white.opacity(0.1)))),
      headerLayer: .init(
        background: .blur(
          dark: true,
          overlay: HelloColor(r: 0.01, g: 0.01, b: 0.01, a: 0.36),
          border: .init(color: .white.opacity(0.1)))),
      floatingLayer: .init(
        background: .blur(
          dark: true,
          overlay: HelloColor(r: 0.01, g: 0.01, b: 0.01, a: 0.32),
          border: .init(color: .white.opacity(0.1)))),
      surfaceLayer: .init(
        background: .color(color: .white.opacity(0.04),
                           border: .init(color: .white.opacity(0.1)))),
      surfaceSectionLayer: .init(
        background: .color(color: .white.opacity(0.08),
                           border: .init(color: .white.opacity(0.1))))
    )
  }
}

public extension HelloTheme {
  
  static var darkk: HelloTheme {
    HelloTheme(
      id: "dark-blur",
      name: "Dark Blur",
      scheme: .dark,
      baseLayer: .init(
        background: .color(color: .greyscale(0.08),
                           border: .init(color: .white.opacity(0.1)))),
      headerLayer: .init(
        background: .blur(
          dark: true,
          overlay: HelloColor(r: 0.01, g: 0.01, b: 0.01, a: 0.36),
          border: .init(color: .white.opacity(0.1)))),
      floatingLayer: .init(
        background: .blur(
          dark: true,
          overlay: HelloColor(r: 0.01, g: 0.01, b: 0.01, a: 0.32),
          border: .init(color: .white.opacity(0.1)))),
      surfaceLayer: .init(
        background: .color(color: .greyscale(0.12),
                           border: .init(color: .white.opacity(0.1)))),
      surfaceSectionLayer: .init(
        background: .color(color: .greyscale(0.2),
                           border: .init(color: .white.opacity(0.1))))
    )
  }
}

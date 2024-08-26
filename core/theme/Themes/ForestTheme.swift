import Foundation

public extension HelloTheme {
  
  static var forest: HelloTheme {
    HelloTheme(
      id: "forest",
      name: "Forest",
      scheme: .dark,
      baseLayer: .init(
        background: .color(color: .forest.green1),
        foregroundPrimary: .color(color: .forest.yellow),
        accent: .color(color: .retroApple.yellow)
      ),
      headerLayer: .init(
        background: .blur(dark: true, overlay: .forest.green1.opacity(0.8)),
        foregroundPrimary: .color(color: .forest.yellow)
      ),
      floatingLayer: .init(
        background: .color(color: .forest.green2),
        foregroundPrimary: .color(color: .forest.yellow)
      ),
      surfaceLayer: .init(
        background: .color(color: .forest.green2),
        foregroundPrimary: .color(color: .forest.yellow)
      ),
      surfaceSectionLayer: .init(
        background: .color(color: .forest.green3),
        foregroundPrimary: .color(color: .forest.yellow)
      ))
  }
}

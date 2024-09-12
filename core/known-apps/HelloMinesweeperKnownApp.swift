import Foundation

public extension KnownApp {
  static var helloMinesweeper: KnownApp {
    KnownApp(
      id: "hello-minesweeper",
      int: 3,
      bundleID: "com.adrianensan.minesweeper",
      name: "Hello Minesweeper",
      url: "",
      platforms: [.iOS])
  }
}

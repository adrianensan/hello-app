import Foundation

public extension KnownApp {
  static var helloMinesweeper: KnownApp {
    KnownApp(
      id: "hello-minesweeper",
      int: 3,
      bundleID: "com.adrianensan.minesweeper",
      appleID: "1583978000",
      name: "Hello Minesweeper",
      description: "High quality minesweeper",
      platforms: [.iOS])
  }
}

import Foundation

public extension KnownApp {
  static var helloSolitaire: KnownApp {
    KnownApp(
      id: "hello-solitaire",
      int: 2,
      bundleID: "com.adrianensan.solitaire",
      appleID: "1576923130",
      name: "Hello Solitaire",
      description: "Klondike, FreeCell and Spider solitaire.",
      platforms: [.iOS])
  }
}

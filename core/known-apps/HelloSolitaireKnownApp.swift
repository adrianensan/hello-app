import Foundation

public extension KnownApp {
  static var helloSolitaire: KnownApp {
    KnownApp(
      id: "hello-solitaire",
      int: 2,
      bundleID: "com.adrianensan.solitaire",
      name: "Hello Solitaire",
      url: "",
      platforms: [.iOS])
  }
}

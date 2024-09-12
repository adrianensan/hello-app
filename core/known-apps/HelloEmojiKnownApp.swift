import Foundation

public extension KnownApp {
  static var helloEmoji: KnownApp {
    KnownApp(
      id: "hello-emoji",
      int: 4,
      bundleID: "com.adrianensan.hello-emoji",
      name: "Hello Emoji",
      url: "",
      platforms: [.iMessage])
  }
}

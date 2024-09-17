import Foundation

public extension KnownApp {
  static var helloEmoji: KnownApp {
    KnownApp(
      id: "hello-emoji",
      int: 4,
      bundleID: "com.adrianensan.hello-emoji",
      appleID: "6468196358",
      name: "Hello Emoji",
      description: "Over 1300 fully animated emoji iMessage stickers.",
      platforms: [.iMessage])
  }
}

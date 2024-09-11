import Foundation

public extension KnownApp {
  static var helloPasswords: KnownApp {
    KnownApp(
      id: "hello-passwords",
      bundleID: "com.adrianensan.passwords",
      name: "Hello Passwords",
      url: "",
      platforms: [.iOS])
  }
}

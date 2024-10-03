import Foundation

public extension KnownApp {
  static var helloPasswords: KnownApp {
    KnownApp(
      id: "hello-passwords",
      int: 5,
      bundleID: "com.adrianensan.passwords",
      appleID: "6502266745",
      name: "Hello Passwords",
      description: "Securily store your passwords, credit cards and much more",
      platforms: [.iOS])
  }
}

import Foundation

public extension KnownApp {
  static var helloPodcasts: KnownApp {
    KnownApp(
      id: "hello-podcasts",
      int: 1,
      bundleID: "com.adrianensan.podcasts",
      name: "Hello Podcasts",
      url: "",
      platforms: [.iOS])
  }
}

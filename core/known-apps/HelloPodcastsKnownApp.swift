import Foundation

public extension KnownApp {
  static var helloPodcasts: KnownApp {
    KnownApp(
      id: "hello-podcasts",
      int: 1,
      bundleID: "com.adrianensan.podcasts",
      appleID: "1554541767",
      name: "Hello Podcasts",
      description: "Easy to use Podcast Player",
      platforms: [.iOS])
  }
}

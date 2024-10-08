import Foundation

public enum AppStoreURLGenerator {
  public static func url(for appID: String) -> String {
    "https://apps.apple.com/app/id\(appID)"
  }
}


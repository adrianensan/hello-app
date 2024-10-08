#if os(iOS)
import UIKit

@MainActor
public func exitGracefully() {
  UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
  Task {
    try await Task.sleep(seconds: 1)
    exit(0)
  }
}
#endif

import Foundation
import Observation

@MainActor
@Observable
public class HelloClock {
  public enum HelloClockState {
    case tik
    case tok
  }
  
  public var state: HelloClockState = .tik
  private var task: Task<Void, any Error>?
  private let tikRate: Double
  
  public init(tikRate: Double) {
    self.tikRate = tikRate
  }
  
  public func start() {
    guard task == nil else { return }
    let tikRate = tikRate
    task = Task {
      do {
        while true {
          try await Task.sleep(seconds: tikRate)
          state = state == .tik ? .tok : .tik
        }
      } catch {}
      task = nil
    }
  }
  
  public func stop() {
    task?.cancel()
  }
}

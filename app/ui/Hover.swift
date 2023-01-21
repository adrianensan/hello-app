import SwiftUI

@MainActor
public class HoverManager: ObservableObject {
  
  public static var main = HoverManager()
  
  @Published public var currentHover: String?
  
}

private struct CurrentHoverEnvironmentKey: EnvironmentKey {
  static let defaultValue: String? = nil
}

public extension EnvironmentValues {
  var currentHover: String? {
    get { self[CurrentHoverEnvironmentKey.self] }
    set { self[CurrentHoverEnvironmentKey.self] = newValue }
  }
}

struct HoverableViewModifier: ViewModifier {
  
  @ObservedObject var hoverModel: HoverManager = .main
  
  var id: String
  
  init(id: String) {
    self.id = id
  }
  
  func body(content: Content) -> some View {
    #if os(iOS) || os(macOS)
    content
      .onHover {
        if $0 {
          hoverModel.currentHover = id
        } else if hoverModel.currentHover == id {
          hoverModel.currentHover = nil
        }
      }
    #else
    content
    #endif
  }
}

public extension View {
  func hover(id: String) -> some View {
    modifier(HoverableViewModifier(id: id))
  }
}

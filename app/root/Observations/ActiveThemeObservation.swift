import SwiftUI

import HelloCore

public extension EnvironmentValues {
  @Entry var theme: HelloSwiftUITheme = HelloSwiftUITheme(theme: .helloLight)
  @Entry var contentShape: AnyInsettableShape? = nil
  @Entry var viewShape: AnyInsettableShape = .rect
  @Entry var pageShape: AnyInsettableShape = .rect
  @Entry var windowCornerRadius: CGFloat = 0
  @Entry var isActive: Bool = true
  @Entry var hasAppeared: Bool = true
  @Entry var hasAppliedTheme: Bool = false
  @Entry var dismissProgress: CGFloat?
  @Entry var needsBlur: Bool = false
  @Entry var needsContrast: Bool = false
  @Entry var viewID: String? = nil
  @Entry var popupID: String? = nil
  @Entry var pageID: String? = nil
  @Entry var windowFrame: CGRect = .zero
  @Entry var viewFrame: CGRect = .zero
  @Entry var safeArea: EdgeInsets = EdgeInsets()
  @Entry var keyboardFrame: CGRect = .zero
  @Entry var isFullscreen: Bool = false
  @Entry var physicalScale: CGFloat = 1
  @Entry var pixelsPerPoint: CGFloat = 1
  @Entry var helloPagerConfig: HelloPagerConfig = HelloPagerConfig()
  @Entry var helloDismiss: @MainActor () -> Void = {}
  @Entry var share: @MainActor (_ items: Any) -> Void = { items in
    #if os(iOS)
    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
      .keyWindow?
      .rootViewController?
      .present(UIActivityViewController(activityItems: (items as? [Any]) ?? [items], applicationActivities: nil), animated: true, completion: nil)
    #endif
  }
}

//struct OptionalEnvironmentKey<ObservableType: Observable>: EnvironmentKey {
//  static let defaultValue: ObservableType? = nil
//}

extension EnvironmentValues: @unchecked @retroactive Sendable {}

//struct AllKey: EnvironmentKey {
//  static let defaultValue: EnvironmentValues = .init()
//}
//
//public extension EnvironmentValues {
//  var all: EnvironmentValues {
//    get { self }
//    set { self = newValue }
//  }
//}

struct AllKey: EnvironmentKey {
  static let defaultValue: EnvironmentValues = .init()
}

extension EnvironmentValues {
  var all: EnvironmentValues {
    get { self }
    set { self = newValue }
  }
}

fileprivate extension EnvironmentValues {
  func optionalObject<ObservableType: Observable & AnyObject>(_ key: ObservableType.Type) -> ObservableType? {
    self[key]
  }
}

@propertyWrapper public struct OptionalEnvironment<ObservableType: Observable & AnyObject>: DynamicProperty {
  
  @Environment(\.all) private var environment
  
  public var wrappedValue: ObservableType?
  
  public init(_ key: ObservableType.Type) { }
  
  mutating public func update() {
    wrappedValue = environment[ObservableType.self]
  }
}

struct ActiveThemeObservationViewModifier: ViewModifier {
  
  @Environment(\.colorScheme) private var colorScheme
  
  private var themeManager: ActiveThemeManager = .main
  
  private var activeTheme: HelloTheme {
    themeManager.activeTheme(for: colorScheme == .dark ? .dark : .light)
  }
  
  private var activeSwiftUITheme: HelloSwiftUITheme {
    HelloSwiftUITheme(theme: activeTheme)
  }
  
  @State private var isActive: Bool = false
  
  func body(content: Content) -> some View {
    content
      .applyTheme()
      .environment(\.theme, activeSwiftUITheme)
      .animation(.easeInOut(duration: 0.2), value: activeTheme.id)
  }
}

@MainActor
public extension View {
  func observeActiveTheme() -> some View {
    modifier(ActiveThemeObservationViewModifier())
  }
}

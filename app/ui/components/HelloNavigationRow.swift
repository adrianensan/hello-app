import SwiftUI

import HelloCore
import HelloApp

public struct HelloNavigationRow: View {
  
  public enum ActionIcon: Sendable {
    case arrow
    case openExternal
    case custom(String)
    
    var iconName: String {
      switch self {
      case .arrow: "chevron.right"
      case .openExternal: "arrow.up.forward.app"
      case .custom(let iconName): iconName
      }
    }
  }
  
  @Environment(\.theme) private var theme
  
  private var icon: String?
  private var iconYOffset: CGFloat
  private var name: String
  private var description: String?
  private var previewContent: (@MainActor () -> AnyView)?
  private var actionIcon: ActionIcon?
  
  public init(icon: String?,
              iconYOffset: CGFloat = 0,
              name: String,
              description: String? = nil,
              actionIcon: ActionIcon? = nil,
              @ViewBuilder trailingContent: @MainActor @escaping () -> some View) {
    self.icon = icon
    self.iconYOffset = iconYOffset
    self.name = name
    self.description = description
    self.actionIcon = actionIcon
    self.previewContent = { @MainActor in AnyView(trailingContent()) }
  }
  
  public init(icon: String?,
              iconYOffset: CGFloat = 0,
              name: String,
              description: String? = nil,
              actionIcon: ActionIcon? = nil) {
    self.icon = icon
    self.iconYOffset = iconYOffset
    self.name = name
    self.description = description
    self.actionIcon = actionIcon
    self.previewContent = nil
  }
  
  public var body: some View {
    HelloSectionItem(leadingPadding: icon != nil) {
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 4) {
          if let icon {
            Image(systemName: icon)
              .font(.system(size: 20, weight: .regular))
              .frame(width: 32, height: 32)
              .offset(y: iconYOffset)
//              .foregroundStyle(theme.surface.foreground.tertiary.style)
          }
          Text(name)
            .font(.system(size: 16, weight: .regular))
            .fixedSize()
          Spacer(minLength: 8)
          if let previewContent {
            previewContent()
          }
          if let actionIcon {
            Image(systemName: actionIcon.iconName)
              .font(.system(size: 16, weight: .regular))
              .foregroundStyle(theme.surface.foreground.tertiary.style)
          }
        }
        if let description {
          Text(description)
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(theme.surface.foreground.tertiary.style)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, icon != nil ? 36 : 0)
            .padding(.trailing, 64)
        }
      }
    }
  }
}

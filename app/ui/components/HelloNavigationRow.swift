import SwiftUI

import HelloCore

public struct HelloNavigationRow: View {
  
  public enum `Type`: Sendable {
    case normal
    case destructive
    case deprioritized
  }
  
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
  private var type: `Type`
  private var previewContent: (@MainActor () -> AnyView)?
  private var actionIcon: ActionIcon?
  private var dividerLeadingPadding: CGFloat
  
  public init(type: `Type` = .normal,
              icon: String? = nil,
              iconYOffset: CGFloat = 0,
              name: String,
              description: String? = nil,
              actionIcon: ActionIcon? = nil,
              dividerLeadingPadding: CGFloat? = nil,
              @ViewBuilder trailingContent: @MainActor @escaping () -> some View) {
    self.type = type
    self.icon = icon
    self.iconYOffset = iconYOffset
    self.name = name
    self.description = description
    self.actionIcon = actionIcon
    self.dividerLeadingPadding = dividerLeadingPadding ?? (icon != nil ? 52 : 0)
    self.previewContent = { @MainActor in AnyView(trailingContent()) }
  }
  
  public init(type: `Type` = .normal,
              icon: String? = nil,
              iconYOffset: CGFloat = 0,
              name: String,
              description: String? = nil,
              actionIcon: ActionIcon? = nil,
              dividerLeadingPadding: CGFloat? = nil) {
    self.type = type
    self.icon = icon
    self.iconYOffset = iconYOffset
    self.name = name
    self.description = description
    self.actionIcon = actionIcon
    self.dividerLeadingPadding = dividerLeadingPadding ?? (icon != nil ? 52 : 0)
    self.previewContent = nil
  }
  
  private var foregroundStyle: Color {
    switch type {
    case .normal:
      theme.surface.foreground.primary.color
    case .destructive:
      theme.surface.error.color
    case .deprioritized:
      theme.surface.foreground.tertiary.color
    }
  }
  
  public var body: some View {
    HelloSectionItem(leadingDividerPadding: dividerLeadingPadding) {
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
            .lineLimit(1)
            .minimumScaleFactor(0.8)
          Spacer(minLength: 8)
          if let previewContent {
            previewContent()
              .font(theme.font(size: 14, weight: .regular))
              .foregroundStyle(theme.surface.foreground.tertiary.style)
              .lineLimit(1)
              .minimumScaleFactor(0.8)
          }
          if let actionIcon {
            Image(systemName: actionIcon.iconName)
              .font(.system(size: 16, weight: .regular))
              .foregroundStyle(theme.surface.foreground.tertiary.style)
          }
        }.foregroundStyle(foregroundStyle)
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

import SwiftUI

import HelloCore

public struct HelloMenuItem: Identifiable {
  public var id: String
  var name: String
  var icon: String
  var isSelected: Bool
  var isDestructive: Bool
  var action: @MainActor () async throws -> Void
  var shareURL: URL?
  var shareString: String?
  
  public init(id: String = .uuid,
              name: String,
              icon: String,
              isSelected: Bool = false,
              isDestructive: Bool = false,
              action: @MainActor @escaping () async throws -> Void) {
    self.id = id
    self.name = name
    self.icon = icon
    self.isSelected = isSelected
    self.isDestructive = isDestructive
    self.action = action
  }
  
  fileprivate init(id: String = .uuid,
                   name: String,
                   icon: String,
                   url: URL) {
    self.id = id
    self.name = name
    self.icon = icon
    self.isSelected = false
    isDestructive = false
    self.action = {}
    self.shareURL = url
  }
  
  fileprivate init(id: String = .uuid,
                   name: String,
                   icon: String,
                   string: String) {
    self.id = id
    self.name = name
    self.icon = icon
    self.isSelected = false
    isDestructive = false
    self.action = {}
    self.shareString = string
  }
  
#if os(iOS)
  public static func copy(string: String) -> HelloMenuItem {
    HelloMenuItem(name: "Copy", icon: "doc.on.doc", action: { UIPasteboard.general.string = string })
  }
  
  public static func copy(url: URL) -> HelloMenuItem {
    HelloMenuItem(name: "Copy", icon: "doc.on.doc", action: {
      UIPasteboard.general.string = url.absoluteString
      UIPasteboard.general.url = url
    })
  }
  
  public static func open(url: URL) -> HelloMenuItem {
    HelloMenuItem(name: "Open", icon: "arrow.up.right.square", action: {
      UIApplication.shared.open(url)
    })
  }
  
  public static func share(string: String) -> HelloMenuItem {
    HelloMenuItem(id: "share-\(String.uuid)", name: "Share", icon: "square.and.arrow.up", string: string)
  }
  
  public static func share(url: URL) -> HelloMenuItem {
    HelloMenuItem(id: "share-\(String.uuid)", name: "Share", icon: "square.and.arrow.up", url: url)
  }
#endif
}

public struct HelloMenuRow: View {
  
  @Environment(\.theme) private var theme
  
  var item: HelloMenuItem
  
  public var body: some View {
    HStack(spacing: 0) {
      Image(systemName: item.icon)
        .frame(width: 32)
      Text(item.name)
        .lineLimit(1)
      Spacer(minLength: 0)
      if item.isSelected {
        Image(systemName: "checkmark")
          .frame(width: 32)
      }
    }.font(.system(size: 14, weight: .medium))
      .foregroundStyle(item.isDestructive ? theme.error.color : theme.foreground.primary.color)
      .padding(.horizontal, 4)
      .frame(width: 240, height: 44)
      .clickable()
      .overlay {
        theme.text.primary.color.opacity(0.1)
          .frame(height: 1)
          .offset(y: -1)
          .frame(maxHeight: .infinity, alignment: .top)
      }
  }
}

public struct HelloMenu: View {
  
  @Environment(\.theme) private var theme
  
  private var position: CGPoint
  private var anchor: Alignment = .topTrailing
  private var items: [HelloMenuItem]
  
  public init(position: CGPoint,
              anchor: Alignment = .topTrailing,
              items: [HelloMenuItem]) {
    self.position = position
    self.anchor = anchor
    self.items = items
  }
  
  public var body: some View {
    PopupViewWrapper(position: position,
                     size: CGSize(width: 240, height: CGFloat(items.count) * 44),
                     anchor: anchor) { isVisible in
      VStack(spacing: 0) {
        ForEach(items) { item in
          if let url = item.shareURL {
            HelloShareLink(url: url, clickStyle: .highlight) {
              HelloMenuRow(item: item)
            }
          } else if let string = item.shareString {
            ShareLink(item: string) {
              HelloMenuRow(item: item)
            }
          } else {
            HelloButton(clickStyle: .highlight, action: {
              isVisible.wrappedValue = false
              try await item.action()
            }) {
              HelloMenuRow(item: item)
            }.environment(\.contentShape, .rect)
          }
        }
      }.clipShape(.rect(cornerRadius: 12))
        .background(theme.floating.backgroundView(for: .rect(cornerRadius: 12)))
    }
  }
}

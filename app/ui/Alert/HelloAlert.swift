import SwiftUI

import HelloCore

public struct HelloAlertConfig {
  
  public struct HelloAlertViewItem {
    var name: String
    var action: (@MainActor () -> Void)?
    var isDestructive: Bool
    
    public init(name: String, action: (@MainActor () -> Void)? = nil, isDestructive: Bool = false) {
      self.name = name
      self.action = action
      self.isDestructive = isDestructive
    }
    
    public init(name: String, action: (@MainActor () async throws -> Void)? = nil, isDestructive: Bool = false) {
      self.name = name
      self.action = { Task { try await action?() } }
      self.isDestructive = isDestructive
    }
    
    public static func ok(action: (@MainActor () -> Void)? = nil) -> HelloAlertViewItem {
      HelloAlertViewItem(name: "OK", action: action, isDestructive: false)
    }
    
    public static func cancel(action: (@MainActor () -> Void)? = nil) -> HelloAlertViewItem {
      HelloAlertViewItem(name: "Cancel", action: action, isDestructive: false)
    }
    
    public static var ok: HelloAlertViewItem { ok() }
    
    public static var cancel: HelloAlertViewItem { cancel() }
  }
  
  var id: String = .uuid
  var title: String
  var message: String?
  var firstButton: HelloAlertViewItem
  var secondButton: HelloAlertViewItem?
  
  public init(title: String,
              message: String? = nil,
              firstButton: HelloAlertViewItem,
              secondButton: HelloAlertViewItem? = nil) {
    self.title = title
    self.message = message
    self.firstButton = firstButton
    self.secondButton = secondButton
  }
}

public struct HelloAlert: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  
  @State private var animateIn: Bool = false
  @State private var isDismissed: Bool = false
  @State private var timeAppeared: TimeInterval = epochTime
  
  private var config: HelloAlertConfig
  
  public init(config: HelloAlertConfig) {
    self.config = config
  }
  
  private func dismiss() {
    isDismissed = true
    animateIn = false
    Task {
      try? await Task.sleep(seconds: 0.2)
      windowModel.dismiss(id: config.id)
    }
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 6) {
        Text(config.title)
          .font(.system(size: 17, weight: .medium))
          .foregroundStyle(theme.foreground.primary.color)
          .fixedSize(horizontal: false, vertical: true)
        
        if let message = config.message {
          Text(message)
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(theme.foreground.primary.style)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
      }.padding(16)
      
      theme.foreground.primary.color.opacity(0.1)
        .frame(height: 1)
      
      HStack(spacing: 0) {
        HelloButton(clickStyle: .highlight, action: {
          config.firstButton.action?()
          dismiss()
        }) {
          Text(config.firstButton.name)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(config.firstButton.isDestructive ? theme.error.style : theme.accent.style)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .clickable()
//            .background(theme.rowBackground.swiftuiColor)
        }.environment(\.contentShape, .rect)
        
        if let secondButton = config.secondButton {
          theme.foreground.primary.color.opacity(0.1)
            .frame(width: 1, height: 44)
          HelloButton(clickStyle: .highlight, action: {
            secondButton.action?()
            dismiss()
          }) {
            Text(secondButton.name)
              .font(.system(size: 17, weight: .semibold))
              .foregroundStyle(secondButton.isDestructive ? theme.error.style : theme.accent.style)
              .frame(height: 44)
              .frame(maxWidth: .infinity)
              .clickable()
//              .background(theme.rowBackground.swiftuiColor)
          }.environment(\.contentShape, .rect)
        }
      }
    }.frame(width: 280)
      .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
      .background(theme.floating.backgroundView(for: RoundedRectangle(cornerRadius: 16, style: .continuous)))
//      .background(theme.background)
//      .componentBackground(color: theme.rowBackground, RoundedRectangle(cornerRadius: 12, style: .continuous))
      .compositingGroup()
      .shadow(color: .black.opacity(0.2), radius: 24)
      .scaleEffect(animateIn ? 1 : 0.6)
      .opacity(animateIn ? 1 : 0)
      .animation(animateIn ? .dampSpring : .easeInOut(duration: 0.2), value: animateIn)
      .onTapGesture {}
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(HelloBackgroundDimmingView()
        .opacity(animateIn ? 0.5 : 0)
        .onTapGesture {
          guard epochTime - timeAppeared > 1 else { return }
          dismiss()
        }
        .animation(.easeInOut(duration: 0.2), value: animateIn))
      .allowsHitTesting(!isDismissed)
      .onAppear { animateIn = true }
  }
}

import SwiftUI

public struct HelloAlertConfig {
  
  public struct HelloAlertViewItem {
    var name: String
    var action: (() -> Void)?
    var isDestructive: Bool
    
    public init(name: String, action: (() -> Void)? = nil, isDestructive: Bool = false) {
      self.name = name
      self.action = action
      self.isDestructive = isDestructive
    }
    
    public init(name: String, action: (() async -> Void)? = nil, isDestructive: Bool = false) {
      self.name = name
      self.action = { Task { await action?() } }
      self.isDestructive = isDestructive
    }
    
    public static func ok(action: (() -> Void)? = nil) -> HelloAlertViewItem {
      HelloAlertViewItem(name: "OK", action: action, isDestructive: false)
    }
    
    public static func cancel(action: (() -> Void)? = nil) -> HelloAlertViewItem {
      HelloAlertViewItem(name: "Cancel", action: action, isDestructive: false)
    }
  }
  
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
  
  @Environment(\.theme) var theme
  
  @EnvironmentObject var uiConstants: UIProperties
  @EnvironmentObject var windowModel: HelloWindowModel
  
  @State var animateIn: Bool = false
  @State var isDismissed: Bool = false
  
  var config: HelloAlertConfig
  
  public init(config: HelloAlertConfig) {
    self.config = config
  }
  
  func dismiss() {
    isDismissed = true
    animateIn = false
    Task {
      try await Task.sleep(seconds: 0.02)
      windowModel.dismissAlert()
    }
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 6) {
        Text(config.title)
          .font(.system(size: 17, weight: .medium, design: .rounded))
          .foregroundColor(theme.text.primaryColor)
          .fixedSize(horizontal: false, vertical: true)
        
        if let message = config.message {
          Text(message)
            .font(.system(size: 13, weight: .regular, design: .rounded))
            .foregroundColor(theme.text.primaryColor)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
      }.padding(16)
      
      theme.text.primaryColor.opacity(0.1)
        .frame(height: 1)
      
      HStack(spacing: 0) {
        Button(action: {
          config.firstButton.action?()
          dismiss()
          ButtonHaptics.buttonFeedback()
        }) {
          Text(config.firstButton.name)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(config.firstButton.isDestructive ? .red : theme.accentColor)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
//            .background(theme.rowBackground.swiftuiColor)
        }.buttonStyle(.highlight)
        
        if let secondButton = config.secondButton {
          theme.text.primaryColor.opacity(0.1)
            .frame(width: 1, height: 44)
          Button(action: {
            secondButton.action?()
            dismiss()
            ButtonHaptics.buttonFeedback()
          }) {
            Text(secondButton.name)
              .font(.system(size: 17, weight: .semibold, design: .rounded))
              .foregroundColor(secondButton.isDestructive ? .red : theme.accentColor)
              .frame(height: 44)
              .frame(maxWidth: .infinity)
//              .background(theme.rowBackground.swiftuiColor)
          }.buttonStyle(.highlight)
        }
      }
    }.frame(width: 280)
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      .background(theme.backgroundView(for: RoundedRectangle(cornerRadius: 12, style: .continuous),
                                       isBaseLayer: false))
//      .background(theme.background)
//      .componentBackground(color: theme.rowBackground, RoundedRectangle(cornerRadius: 12, style: .continuous))
      .compositingGroup()
      .shadow(color: .black.opacity(0.2), radius: 24)
      .scaleEffect(animateIn ? 1 : 0.6)
      .opacity(animateIn ? 1 : 0)
      .animation(animateIn ? .dampSpring : .easeInOut(duration: 0.25), value: animateIn)
      .onTapGesture {}
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.black
        .opacity(animateIn ? 0.4 : 0)
        .onTapGesture { dismiss() }
        .animation(.easeInOut(duration: 0.2), value: animateIn))
      .allowsHitTesting(!isDismissed)
      .onAppear { animateIn = true }
  }
}

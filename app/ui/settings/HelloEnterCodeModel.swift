#if os(iOS)
import SwiftUI

import HelloCore

@MainActor
@Observable
public class HelloEnterCodeModel {
  
  @ObservationIgnored @Persistent(.isDeveloper) private var isDeveloper
  @ObservationIgnored @Persistent(.isFakeDeveloper) private var isFakeDeveloper
  
  var clicksRequired: Int = 10
  
  var id: String = .uuid
  weak var windowModel: HelloWindowModel?
  
  var unlockDevModeClickCount: Int = 0
  @ObservationIgnored private var unlockDevModeLastClick: TimeInterval = 0
  var logoFrame: CGRect = .zero
  
  var input: String = ""
  var presented: Bool = false
  var allowInteraction: Bool = false
  var blurTask: Task<Void, any Error>?
  
  public var progress: CGFloat = 0
  
  public func click() {
    if epochTime - unlockDevModeLastClick >= 1 {
      input = ""
      unlockDevModeClickCount = 1
    }
    
    unlockDevModeLastClick = epochTime
    
    guard !presented else { return }
    if windowModel?.isPresenting(id) == false {
      windowModel?.present(id: id, hasExclusiveInteraction: false) { HelloEnterCodeOverlay().environment(self) }
    }
    unlockDevModeClickCount += 1
    progress = CGFloat(unlockDevModeClickCount) / CGFloat(clicksRequired)
    blurTask?.cancel()
    blurTask = Task {
      withAnimation(.easeOut(duration: 0.25)) {
        windowModel?.blurAmountForPopup = progress * 16
      }
      if unlockDevModeClickCount < clicksRequired {
        try await Task.sleep(seconds: 0.3)
        withAnimation(.easeInOut(duration: 1)) {
          windowModel?.blurAmountForPopup = 0
          progress = 0
        }
        
        try await Task.sleep(seconds: 1)
        unlockDevModeClickCount = 0
        windowModel?.dismiss(id: id)
      }
    }
    if unlockDevModeClickCount >= clicksRequired {
      presented = true
      Task {
        try? await Task.sleep(seconds: 1)
        allowInteraction = true
      }
    }
    Haptics.shared.feedback(intensity: 0.2 + 0.8 * Float(progress))
  }
  
  public func enter() {
    let input = input
    dismiss()
    switch input.lowercased() {
    case "admin", "developer", "debug", "debugmode":
      if !isFakeDeveloper && !isDeveloper {
        windowModel?.show(alert: HelloAlertConfig(
          title: "Enable Developer Mode",
          message: "This will reveal access to logs, debug options, file management and more.\n\nWarning, you will easily be able to mess up the app if you delete the wrong files.",
          firstButton: .cancel,
          secondButton: .init(name: "Enable", action: { self.isFakeDeveloper = true }, isDestructive: true)))
      } else {
        windowModel?.show(alert: HelloAlertConfig(
          title: "Developer Mode Enabled",
          message: #"Access developer options through the "Developer" settings menu"#,
          firstButton: .ok))
      }
    case "exit", "close": exitGracefully()
    case "crash": exit(0)
    case "freeze": windowModel?.freeze = true
    case "confetti": windowModel?.showConfetti()
    case "cat", "monki", "monkey":
      Task {
        let preloadModel = HelloImageModel.model(for: .asset(bundle: .helloApp, named: "cat"))
        try await Task.sleep(seconds: 0.2)
        windowModel?.showPopup {
          ImageViewer(options: [.init(imageSource: .asset(bundle: .helloApp, named: "cat"), variant: .original)],
                      originalFrame: nil, cornerRadius: 0)
        }
      }
    case "nopromo":
      HelloSubscriptionModel.main.removePromo()
      windowModel?.show(alert: HelloAlertConfig(
        title: "Promo Removed",
        firstButton: .ok))
    case hasPrefix("promo"):
      let promoCode = input.deletingPrefix("promo")
      windowModel?.show(alert: HelloAlertConfig(
        title: "Code Redeemed",
        message: "Premium features are now enabled",
        firstButton: .ok))
      
//      windowModel?.show(alert: HelloAlertConfig(
//        title: "Code Already Redeemed",
//        message: "You already have access to premium features",
//        firstButton: .ok))
//      windowModel?.show(alert: HelloAlertConfig(
//        title: "Invalid promo code",
//        message: "Invalid promo code",
//        firstButton: .ok))
    default:
      if let unixSignal = UNIXSignal(input) {
        exit(0)
      } else if let promoCode: HelloPromoCode = try? .parse(from: input) {
        guard let deviceUUID = try? HelloUUID(string: Persistence.mainActorValue(.deviceID)) else {
          windowModel?.show(alert: HelloAlertConfig(
            title: "Error",
            message: "Failed to parse Device ID",
            firstButton: .ok))
          return
        }
        guard promoCode.deviceIDHash.lowercased() == deviceUUID.shortHashString else {
          windowModel?.show(alert: HelloAlertConfig(
            title: "Nothing Happened",
            message: "Not sure what you expected",
            firstButton: .ok))
          return
        }
        guard !HelloSubscriptionModel.main.allowPremiumFeatures else {
          windowModel?.show(alert: HelloAlertConfig(
            title: "Already Premium",
            message: "Premium features are already enabled",
            firstButton: .ok))
          return
        }
        
        guard promoCode.appInt == 0 || promoCode.appInt == KnownApp.app(for: AppInfo.rootBundleID)?.int else {
          windowModel?.show(alert: HelloAlertConfig(
            title: "Premium Enabled",
            message: "Premium features are now enabled",
            firstButton: .ok))
          return
        }
        
        HelloSubscriptionModel.main.applyPromo(global: promoCode.appInt == 0)
        
        windowModel?.show(alert: HelloAlertConfig(
          title: "Premium Enabled",
          message: "Premium features are now enabled",
          firstButton: .ok))
      } else {
        windowModel?.show(alert: HelloAlertConfig(
          title: "Nothing Happened",
          message: "Not sure what you expected",
          firstButton: .ok))
      }
    }
  }
  
  public func cancel() {
    dismiss()
  }
  
  private func dismiss() {
    Task {
      allowInteraction = false
      presented = false
      try? await Task.sleepForOneFrame()
      withAnimation(.easeOut(duration: 0.8)) {
        progress = 0
        presented = false
      }
      
      try? await Task.sleepForOneFrame()
      windowModel?.dismiss(id: id)
    }
  }
}
#endif

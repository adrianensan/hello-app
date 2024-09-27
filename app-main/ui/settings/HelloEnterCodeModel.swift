#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

@MainActor
@Observable
public class HelloEnterCodeModel {
  
  @ObservationIgnored @Persistent(.isDeveloper) private var isDeveloper
  @ObservationIgnored @Persistent(.isFakeDeveloper) private var isFakeDeveloper
  
  var clicksRequired: Int = 10
  
  var id: String = .uuid
  weak var windowModel: HelloWindowModel?
  weak var pagerModel: PagerModel?
  
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
    var alertTitle: String?
    var alertMessage: String?
    switch input.lowercased() {
    case "admin", "developer", "debug", "debugmode":
      if !isFakeDeveloper && !isDeveloper {
        windowModel?.show(alert: HelloAlertConfig(
          title: "Enable Developer Mode",
          message: "This will reveal access to logs, debug options, file management and more.\n\nWarning, you will easily be able to mess up the app if you delete the wrong files.",
          firstButton: .cancel,
          secondButton: .init(name: "Enable", action: { self.isFakeDeveloper = true }, isDestructive: true)))
      } else {
        alertTitle = "Developer Mode Enabled"
        alertMessage = #"Access developer options through the "Developer" settings menu"#
      }
    case "exit", "close": exitGracefully()
    case "crash": exit(0)
    case "knockknock": alertTitle = "Who's There"
    case "freeze": windowModel?.freeze = true
    case "confetti": windowModel?.showConfetti()
    case "cat", "cats", "pet", "pets", "monki", "monkey":
      Task {
        try await Task.sleep(seconds: 0.5)
        pagerModel?.push { CatPage() }
      }
    case "nopromo":
      if helloApplication.appConfig.hasPremiumFeatures {
        HelloSubscriptionModel.main.removePromo()
        alertTitle = "Promo Removed"
      } else {
        alertTitle = "Nothing Happened"
        alertMessage = "Not sure what you expected"
      }
    default:
      if let unixSignal = UNIXSignal(input) {
        exit(0)
      } else if let promoCode: HelloPromoCode = try? .parse(from: input) {
        guard helloApplication.appConfig.hasPremiumFeatures else {
          alertTitle = "Nothing Happened"
          alertMessage = "Not sure what you expected"
          break
        }
        
        guard let deviceUUID = try? HelloUUID(string: Persistence.mainActorValue(.deviceID)) else {
          alertTitle = "Nothing Happened"
          alertMessage = "Not sure what you expected"
          break
        }
        guard promoCode.deviceIDHash.lowercased() == deviceUUID.shortHashString else {
          alertTitle = "Nothing Happened"
          alertMessage = "Not sure what you expected"
          break
        }
        guard !HelloSubscriptionModel.main.allowPremiumFeatures else {
          alertTitle = "Already Premium"
          alertMessage = "Premium features are already enabled"
          break
        }
        
        guard promoCode.appInt == 0 || promoCode.appInt == KnownApp.app(for: AppInfo.rootBundleID)?.int else {
          alertTitle = "Nothing Happened"
          alertMessage = "Not sure what you expected"
          break
        }
        
        HelloSubscriptionModel.main.applyPromo(global: promoCode.appInt == 0)
        alertTitle = "Premium Enabled"
        alertMessage = "Premium features are now enabled"
      } else {
        alertTitle = "Nothing Happened"
        alertMessage = "Not sure what you expected"
      }
    }
    if let alertTitle {
      windowModel?.show(alert: HelloAlertConfig(
        title: alertTitle,
        message: alertMessage,
        firstButton: .ok))
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

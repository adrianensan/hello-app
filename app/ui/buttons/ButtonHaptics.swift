import SwiftUI

public enum ButtonHaptics {
  
#if os(iOS)
  private static let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
#endif
  
  public static func buttonFeedback() {
#if os(iOS)
    selectionFeedbackGenerator.selectionChanged()
#elseif os(watchOS)
    WKInterfaceDevice.current().play(.click)
#endif
  }
}

public extension View {
  func buttonHaptics(isPressed: Bool) -> some View {
    onChange(of: isPressed, perform: {
      if $0 {
        ButtonHaptics.buttonFeedback()
      }
    })
  }
}

import HelloCore
import CoreGraphics
#if os(iOS)
import UIKit
import CoreHaptics
#elseif os(watchOS)
import WatchKit
#endif

public class Haptics {
  
  public static let shared: Haptics = Haptics() +& { $0.prepareHaptics() }
  
#if os(iOS) || os(watchOS)
  var hapticsLevel: HapticsLevel {
    (UserDefaults.standard.object(forKey: "hapticsLevel") as? HapticsLevel) ?? .normal
  }
#endif
  
#if os(iOS)
  private static let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
  private static let selectioFeedbackGenerator = UINotificationFeedbackGenerator()
  private static let impactFeedbackGenerator = UIImpactFeedbackGenerator()
  
  private var engine: CHHapticEngine?
  
  static var isSupported: Bool { CHHapticEngine.capabilitiesForHardware().supportsHaptics }
  
  public func prepareHaptics() {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    do {
      engine = try CHHapticEngine() +& {
        $0.playsHapticsOnly = true
        $0.isAutoShutdownEnabled = true
      }
    } catch {
      print("There was an error creating the engine: \(error.localizedDescription)")
    }
  }
  
  public func pulse(count: Int, intensity: Float = 0.75, interval: CGFloat) {
    guard hapticsLevel == .normal else { return }
    
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    var events = [CHHapticEvent]()
    
    for i in 0..<count {
      events.append(CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [
                                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)],
                                  relativeTime: CGFloat(i) * interval))
    }
    
    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: CHHapticTimeImmediate)
    } catch {
      print("Failed to play pattern: \(error.localizedDescription).")
    }
  }
  
  public func invalidMove() {
    // make sure that the device supports haptics
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    var events = [CHHapticEvent]()
    
    do {
      let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
      let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
      let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.0)
      events.append(event)
    }
    
    do {
      let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.75)
      let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
      let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.075)
      events.append(event)
    }
    
    do {
      let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
      let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
      let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.15)
      events.append(event)
    }
    //    do {
    //      let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
    //      let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
    //      let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.1)
    //      events.append(event)
    //    }
    
    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: CHHapticTimeImmediate)
    } catch {
      print("Failed to play pattern: \(error.localizedDescription).")
    }
  }
  
  public func fireworkLaunch() {
    guard hapticsLevel == .normal else { return }
    
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    var events = [CHHapticEvent]()
    
    do {
      let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.75)
      let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
      let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.0)
      events.append(event)
    }
    
    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: CHHapticTimeImmediate)
    } catch {
      print("Failed to play pattern: \(error.localizedDescription).")
    }
  }
  
  public func fireworkExplode() {
    guard hapticsLevel == .normal else { return }
    
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    var events = [CHHapticEvent]()
    
    do {
      let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.75)
      let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
      let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.0)
      events.append(event)
    }
    
    do {
      let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.75)
      let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
      let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.1)
      events.append(event)
    }
    
    do {
      let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.75)
      let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
      let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.2)
      events.append(event)
    }
    
    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: CHHapticTimeImmediate)
    } catch {
      print("Failed to play pattern: \(error.localizedDescription).")
    }
  }
  
  func complexSuccess() {
    // make sure that the device supports haptics
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    var events = [CHHapticEvent]()
    
    // create one intense, sharp tap
    //    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
    //    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
    //    let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
    //    events.append(event)
    
    //    do {
    //    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
    //    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
    //    let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
    //    events.append(event)
    //    }
    //
    do {
      let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
      let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
      let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.0)
      events.append(event)
    }
    
    do {
      let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
      let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
      let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.05)
      events.append(event)
    }
    do {
      let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
      let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
      let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.1)
      events.append(event)
    }
    
    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: CHHapticTimeImmediate)
    } catch {
      print("Failed to play pattern: \(error.localizedDescription).")
    }
  }
  
#else
  static var isSupported: Bool { false }
  public func prepareHaptics() {}
  
  public func pulse(count: Int, intensity: Float = 0.75, interval: CGFloat) {}
  public func invalidMove() {}
  public func fireworkLaunch() {}
  public func fireworkExplode() {}
  public func complexSuccess() {}
#endif
  
  public static func buttonFeedback() {
#if os(iOS) || os(watchOS)
    guard Self.shared.hapticsLevel != .off else { return }
#if os(iOS)
    selectionFeedbackGenerator.selectionChanged()
    // make sure that the device supports haptics
    //shared.complexSuccess()
#elseif os(watchOS)
    WKInterfaceDevice.current().play(.click)
#endif
#endif
  }
  
  public static func notableGoodAction() {
#if os(iOS)
    selectioFeedbackGenerator.notificationOccurred(.success)
#elseif os(watchOS)
    WKInterfaceDevice.current().play(.success)
#endif
  }
  
  public static func notableBadAction() {
#if os(iOS)
    Haptics.shared.invalidMove()
    //selectioFeedbackGenerator.notificationOccurred(.error)
#elseif os(watchOS)
    WKInterfaceDevice.current().play(.failure)
#endif
  }
  
  public static func subtleImpact() {
#if os(iOS) || os(watchOS)
    guard Self.shared.hapticsLevel != .off else { return }
#if os(iOS)
    impactFeedbackGenerator.impactOccurred()
#elseif os(watchOS)
    WKInterfaceDevice.current().play(.click)
#endif
#endif
  }
  
  public static func subtleSelection() {
#if os(iOS) || os(watchOS)
    guard Self.shared.hapticsLevel == .normal else { return }
#if os(iOS)
    selectionFeedbackGenerator.selectionChanged()
#elseif os(watchOS)
    WKInterfaceDevice.current().play(.click)
#endif
#endif
  }
  
}

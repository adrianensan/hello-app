import Foundation

public struct HelloAppIconTint: Codable, Identifiable, Hashable, Sendable {
  public var id: String
  public var foreground: HelloAppIconTintFill
  public var background: HelloAppIconTintFill
}

public extension HelloAppIconTint {
  static var green: HelloAppIconTint { .init(id: "green", foreground: .color(.white), background: .standardGradient(for: .retroApple.green)) }
  static var yellow: HelloAppIconTint { .init(id: "yellow", foreground: .color(.white), background: .standardGradient(for: .retroApple.yellow)) }
  static var orange: HelloAppIconTint { .init(id: "orange", foreground: .color(.white), background: .standardGradient(for: .retroApple.orange)) }
  static var red: HelloAppIconTint { .init(id: "red", foreground: .color(.white), background: .standardGradient(for: .retroApple.red)) }
  static var purple: HelloAppIconTint { .init(id: "purple", foreground: .color(.white), background: .standardGradient(for: .retroApple.purple)) }
  static var blue: HelloAppIconTint { .init(id: "blue", foreground: .color(.white), background: .standardGradient(for: .retroApple.blue)) }
  
  static var white: HelloAppIconTint { .init(id: "white", foreground: .color(.black), background: .standardGradient(for: .white)) }
  static var black: HelloAppIconTint { .init(id: "black", foreground: .color(.white), background: .standardGradient(for: .black)) }
  static var blackDim: HelloAppIconTint { .init(id: "black-dim", foreground: .color(.white.opacity(0.4)), background: .color(.black)) }
  
  static var retroApple: HelloAppIconTint { .init(id: "retro-apple", foreground: .color(.white), background: .colorBlock(HelloColor.retroApple.all)) }
  static var pride: HelloAppIconTint { .init(id: "pride", foreground: .color(.white), background: .colorBlock(HelloColor.pride.all)) }
  
  static var defaultOptions: [HelloAppIconTint] { [
    .blue, .green, .yellow, .orange, .red, .purple, .retroApple, .pride, .white, .black, .blackDim
  ]}
  
}

import Foundation

public extension HelloTheme {
  
  static var crt: HelloTheme {
    HelloTheme(id: "crt-dark",
               name: "CRT",
               scheme: .dark,
               baseLayer: .init(background: .color(color: .black, border: .init(color: .neonGreen, width: 2)),
                                foregroundPrimary: .color(color: .neonGreen),
                                foregroundSecondary: .color(color: .neonGreen),
                                foregroundTertiary: .color(color: .neonGreen),
                                foregroundQuaternary: .color(color: .neonGreen),
                                accent: .color(color: .neonGreen)),
               headerLayer: .init(background: .blur(dark: false, overlay: .black.opacity(0.8)),
                                  foregroundPrimary: .color(color: .neonGreen),
                                  foregroundSecondary: .color(color: .neonGreen),
                                  foregroundTertiary: .color(color: .neonGreen),
                                  foregroundQuaternary: .color(color: .neonGreen)),
               floatingLayer: .init(background: .color(color: .black, border: .init(color: .neonGreen, width: 2)),
                                    foregroundPrimary: .color(color: .neonGreen),
                                    foregroundSecondary: .color(color: .neonGreen),
                                    foregroundTertiary: .color(color: .neonGreen),
                                    foregroundQuaternary: .color(color: .neonGreen)),
               surfaceLayer: .init(background: .color(color: .black, border: .init(color: .neonGreen, width: 2)),
                                   foregroundPrimary: .color(color: .neonGreen),
                                   foregroundSecondary: .color(color: .neonGreen),
                                   foregroundTertiary: .color(color: .neonGreen),
                                   foregroundQuaternary: .color(color: .neonGreen)),
               surfaceSectionLayer: .init(background: .color(color: .black, border: .init(color: .neonGreen, width: 2)),
                                          foregroundPrimary: .color(color: .neonGreen),
                                          foregroundSecondary: .color(color: .neonGreen),
                                          foregroundTertiary: .color(color: .neonGreen),
                                          foregroundQuaternary: .color(color: .neonGreen)))
  }
}

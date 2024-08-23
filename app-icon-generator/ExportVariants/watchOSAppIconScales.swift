import Foundation

public extension IconScale {
  static let watchOSIconScales: [IconScale] = [
    IconScale(size: 24, scaleFactor: 2, purpose: .watch, role: .notificationCenter, subtype: .watch38mm),
    IconScale(size: 27.5, scaleFactor: 2, purpose: .watch, role: .notificationCenter, subtype: .watch42mm),
    IconScale(size: 29, scaleFactor: 2, purpose: .watch, role: .companionSettings),
    IconScale(size: 29, scaleFactor: 3, purpose: .watch, role: .companionSettings),
    IconScale(size: 33, scaleFactor: 2, purpose: .watch, role: .notificationCenter, subtype: .watch45mm),
    IconScale(size: 40, scaleFactor: 2, purpose: .watch, role: .appLauncher, subtype: .watch38mm),
    IconScale(size: 44, scaleFactor: 2, purpose: .watch, role: .appLauncher, subtype: .watch40mm),
    IconScale(size: 46, scaleFactor: 2, purpose: .watch, role: .appLauncher, subtype: .watch41mm),
    IconScale(size: 50, scaleFactor: 2, purpose: .watch, role: .appLauncher, subtype: .watch44mm),
    IconScale(size: 51, scaleFactor: 2, purpose: .watch, role: .appLauncher, subtype: .watch45mm),
    IconScale(size: 86, scaleFactor: 2, purpose: .watch, role: .quickLook, subtype: .watch38mm),
    IconScale(size: 98, scaleFactor: 2, purpose: .watch, role: .quickLook, subtype: .watch42mm),
    IconScale(size: 108, scaleFactor: 2, purpose: .watch, role: .quickLook, subtype: .watch44mm),
    IconScale(size: 117, scaleFactor: 2, purpose: .watch, role: .quickLook, subtype: .watch45mm),
    IconScale(size: 1024, scaleFactor: 1, purpose: .watchMarketing)
  ]
}

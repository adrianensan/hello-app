import Foundation

public struct HelloPromoCode: Sendable {
  public var appInt: Int
  public var deviceIDHash: String
  
  public init(appInt: Int, deviceIDHash: String) {
    self.appInt = appInt
    self.deviceIDHash = deviceIDHash
  }
  
  public var string: String {
    "\(String(appInt, radix: 36, uppercase: true))\(deviceIDHash)".uppercased()
  }
  
  public static func parse(from code: String) throws -> HelloPromoCode {
    guard code.count > 2 else { throw HelloError("Invalid code") }
    guard let appInt = UInt8(String(code[0]), radix: 36) else { throw HelloError("Invalid app int") }
    return HelloPromoCode(appInt: Int(appInt), deviceIDHash: String(code.dropFirst()))
  }
  
  public static func new(for deviceID: String, app: KnownApp? = nil) throws -> HelloPromoCode {
    guard let deviceUUID = try? HelloUUID(string: deviceID) else { throw HelloError("Invalid device ID") }
    return HelloPromoCode(appInt: app?.int ?? 0, deviceIDHash: deviceUUID.shortHashString)
  }
}

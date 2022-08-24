import Foundation

public extension IconScale {
  static var iMessageIconScales: [IconScale] = [
    IconScale(size: 29, scaleFactor: 2, purpose: .iphone),
    IconScale(size: 29, scaleFactor: 3, purpose: .iphone),
    IconScale(size: CGSize(width: 60, height: 45), scaleFactor: 2, purpose: .iphone),
    IconScale(size: CGSize(width: 60, height: 45), scaleFactor: 3, purpose: .iphone),
    IconScale(size: 29, scaleFactor: 2, purpose: .ipad),
    IconScale(size: CGSize(width: 67, height: 50), scaleFactor: 2, purpose: .ipad),
    IconScale(size: CGSize(width: 74, height: 55), scaleFactor: 2, purpose: .ipad),
    
    IconScale(size: 1024, scaleFactor: 1, purpose: .iosMarketing),
    
    IconScale(size: CGSize(width: 27, height: 20), scaleFactor: 2, purpose: .universal, platform: .ios),
    IconScale(size: CGSize(width: 27, height: 20), scaleFactor: 3, purpose: .universal, platform: .ios),
    IconScale(size: CGSize(width: 32, height: 24), scaleFactor: 2, purpose: .universal, platform: .ios),
    IconScale(size: CGSize(width: 32, height: 24), scaleFactor: 3, purpose: .universal, platform: .ios),
    
    IconScale(size: CGSize(width: 1024, height: 768), scaleFactor: 1, purpose: .iosMarketing, platform: .ios)
  ]
}

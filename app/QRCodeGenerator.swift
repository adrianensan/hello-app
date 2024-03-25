import CoreImage

import HelloApp

public enum QRCodeGenerator {
  public func generate(from string: String) -> NativeImage? {
    guard let data = string.data(using: String.Encoding.ascii) else { return nil }
    
    let filter = CIFilter.qrCodeGenerator()
    filter.message = data
    
    guard let ciImage = filter.outputImage else { return nil }
    
    return NativeImage(ciImage: ciImage)
  }
  
  public func generateWiFi(ssid: String, password: String, type: String = "WPA") -> NativeImage? {
    generate(from: "WIFI:S:\(ssid);T:\(type);P:\(password);;")
  }
}

import CoreImage

import HelloApp

public enum QRCodeGenerator {
  public static func generate(from string: String) -> NativeImage? {
    guard let data = string.data(using: String.Encoding.ascii) else { return nil }
    
    let filter = CIFilter.qrCodeGenerator()
    filter.message = data
    
    guard 
      let ciImage = filter.outputImage,
      let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent)
    else { return nil }
    
    return NativeImage(cgImage: cgImage)
  }
  
  public static func generateWiFi(ssid: String, password: String, type: String = "WPA") -> NativeImage? {
    generate(from: "WIFI:S:\(ssid);T:\(type);P:\(password);;")
  }
}

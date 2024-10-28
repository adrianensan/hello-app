#if canImport(CoreImage)
import CoreImage

import HelloCore

public enum QRCodeGenerator {
  public static func generate(from string: String) throws -> NativeImage {
    guard let data = string.data(using: String.Encoding.ascii) else {
      Log.error(context: "QR Code Generator", "String could not be encoded to ASCII")
      throw HelloError("String could not be encoded to ASCII")
    }
    
    let filter = CIFilter.qrCodeGenerator()
    filter.message = data
    
    guard 
      let ciImage = filter.outputImage,
      let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent)
    else {
      Log.error(context: "QR Code Generator", "Failed to generate")
      throw HelloError("Failed to generate")
    }
    
    return NativeImage(cgImage: cgImage)
  }
  
  public static func generateWiFi(ssid: String, password: String, type: String = "WPA") throws -> NativeImage {
    try generate(from: "WIFI:S:\(ssid);T:\(type);P:\(password);;")
  }
}
#endif

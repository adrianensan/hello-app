import SwiftUI

public struct ScaledImage: View {
  
  private var imageName: String
  private var bundle: Bundle
  private var scaleMode: ContentMode
  
  public init(_ imageName: String, bundle: Bundle = .main, scaleMode: ContentMode = .fill) {
    self.imageName = imageName
    self.bundle = bundle
    self.scaleMode = scaleMode
  }
  
  public var body: some View {
    Image(imageName, bundle: bundle)
      .resizable()
      .aspectRatio(contentMode: scaleMode)
  }
}

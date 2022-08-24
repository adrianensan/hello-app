import SwiftUI

public struct ScaledImage: View {
  
  private var imageName: String
  private var bundle: Bundle
  
  public init(_ imageName: String, bundle: Bundle = .main) {
    self.imageName = imageName
    self.bundle = bundle
  }
  
  public var body: some View {
    Image(imageName, bundle: bundle)
      .resizable()
      .aspectRatio(contentMode: .fill)
  }
}

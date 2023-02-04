import SwiftUI

@MainActor
public struct FrameAnimation: View {
  
  private class NonObserved {
    var frame: Int = 0
    var frames: [Int: NativeImage] = [:]
  }
  
  @State private var currentImageFrame: NativeImage?
  @State private var isHidden: Bool = true
  @State private var nonObserved = NonObserved()
  
  private var name: String
  private var initialFrame: Int
  private var lastFrame: Int
  private var delay: TimeInterval
  private var fps: CGFloat
  private var lingerOnLastFrame: Bool
  
  public init(name: String,
              initialFrame: Int,
              lastFrame: Int,
              delay: TimeInterval = 0,
              fps: CGFloat = 60,
              lingerOnLastFrame: Bool = false) {
    self.name = name
    self.initialFrame = initialFrame
    self.lastFrame = lastFrame
    self.delay = delay
    self.fps = fps
    self.lingerOnLastFrame = lingerOnLastFrame
    nonObserved.frame = initialFrame
  }
  
  public var body: some View {
    Image(currentImageFrame ?? NativeImage())
      .resizable()
      .aspectRatio(contentMode: .fit)
      .opacity(isHidden ? 0 : 1)
      .onAppear {
        for i in initialFrame...lastFrame {
          let imageName = String(format: "\(name)%0\(String(lastFrame).count)d", i)
          Task.detached {
            if let nextImage = NativeImage(named: imageName) {
              Task { @MainActor in
                nonObserved.frames[i] = nextImage
              }
            }
          }
        }
        Task {
          try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
          isHidden = false
          for i in initialFrame...lastFrame {
            nonObserved.frame = i
            if let nextImage = nonObserved.frames[nonObserved.frame] {
              currentImageFrame = nextImage
            }
            try await Task.sleep(nanoseconds: UInt64(1 / fps * 1_000_000_000))
          }
          if !lingerOnLastFrame {
            isHidden = true
          }
        }
      }
  }
}

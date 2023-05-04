import SwiftUI

@MainActor
public struct FrameAnimation: View {
  
  public enum RepeatBehaviour: Equatable, Sendable {
    case playOnce
    case loopForever
    case loop(numberOfLoops: Int)
  }
  
  private class NonObserved {
    var isAnimating: Bool = false
    var isActive: Bool = false
    var frame: Int = 0
    var frames: [Int: NativeImage] = [:]
    var loopIteration: Int = 0
    var freezeFrame: Int?
  }
  
  @State private var currentImageFrame: NativeImage?
  @State private var isHidden: Bool = true
  @State private var nonObserved = NonObserved()
  @State private var loopMode: RepeatBehaviour = .playOnce
  @State private var isActive: Bool = false
  
  private var name: String
  private var initialFrame: Int
  private var lastFrame: Int
  private var delay: TimeInterval
  private var fps: CGFloat
  private var lingerOnLastFrame: Bool
  private var repeatBehaviour: RepeatBehaviour
  private var contentMode: ContentMode
  private var resetSignal: Bool
  
  public init(name: String,
              startFrameOverride: Int? = nil,
              initialFrame: Int,
              lastFrame: Int,
              freezeFrame: Int? = nil,
              delay: TimeInterval = 0,
              fps: CGFloat = 60,
              lingerOnLastFrame: Bool = false,
              repeatBehaviour: RepeatBehaviour = .playOnce,
              contentMode: ContentMode = .fit,
              resetSignal: Bool = false) {
    self.name = name
    self.initialFrame = initialFrame
    self.lastFrame = lastFrame
    self.delay = delay
    self.fps = fps
    self.lingerOnLastFrame = lingerOnLastFrame
    self.repeatBehaviour = repeatBehaviour
    self._loopMode = State(initialValue: repeatBehaviour)
    self.contentMode = contentMode
    self.resetSignal = resetSignal
    nonObserved.frame = (startFrameOverride ?? initialFrame)
    nonObserved.freezeFrame = freezeFrame
  }
  
  public func animate() async throws {
    guard nonObserved.isActive && !nonObserved.isAnimating else { return }
    nonObserved.isAnimating = true
    defer { nonObserved.isAnimating = false }
    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    isHidden = false
    while nonObserved.frame < nonObserved.freezeFrame ?? lastFrame {
      nonObserved.frame += 1
      if let nextImage = nonObserved.frames[nonObserved.frame] {
        currentImageFrame = nextImage
      }
      try await Task.sleep(nanoseconds: UInt64(1 / fps * 1_000_000_000))
    }
    switch loopMode {
    case .playOnce: ()
    case .loopForever:
      nonObserved.loopIteration += 1
      nonObserved.frame = initialFrame - 1
      Task {
        try await animate()
      }
      return
    case .loop(let numberOfLoops):
      if nonObserved.loopIteration < numberOfLoops {
        nonObserved.loopIteration += 1
        nonObserved.frame = initialFrame - 1
        Task {
          try await animate()
        }
        return
      }
    }
    if !lingerOnLastFrame {
      isHidden = true
    }
  }
  
  public var body: some View {
    Image(currentImageFrame ?? NativeImage())
      .resizable()
      .aspectRatio(contentMode: contentMode)
      .opacity(isHidden ? 0 : 1)
      .onAppear {
        nonObserved.isActive = true
        for i in initialFrame...lastFrame {
          let imageName = String(format: "\(name)%0\(String(lastFrame).count)d", i)
          Task.detached {
            if let nextImage = NativeImage(named: imageName) {
              Task { @MainActor in
                nonObserved.frames[i] = nextImage
                if i == nonObserved.frame {
                  currentImageFrame = nextImage
                }
              }
            }
          }
        }
        Task { try await animate() }
      }.onChange(of: resetSignal) { _ in
        nonObserved.loopIteration = 0
        nonObserved.freezeFrame = nil
        Task { try await animate() }
      }.onChange(of: repeatBehaviour) { newii in
        loopMode = newii
        nonObserved.loopIteration = 0
        Task { try await animate() }
      }.onDisappear {
        nonObserved.isActive = false
      }
  }
}

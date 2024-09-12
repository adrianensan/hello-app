import SwiftUI

import HelloCore

public struct ConfettiParticle: Identifiable {
  
  static func randomColor() -> Color {
    HelloColor.retroApple.all.randomElement()!.swiftuiColor
  }
  
  public var id: String = UUID().uuidString
  public var delay: TimeInterval
  public var size = CGSize(width: .random(in: 4...8), height: .random(in: 6...12))
  public var color: Color = randomColor()
  public var spinDirX: CGFloat = [-1.0, 1.0].randomElement()!
  public var spinDirZ: CGFloat = [-1.0, 1.0].randomElement()!
  
  public var xSpeed: Double = Double.random(in: 1...2)
  
  public var zSpeed = Double.random(in: 1...2)
  public var anchor = CGFloat.random(in: 0...1).rounded()
  
  public var offset: CGPoint = CGPoint(x: .random(in: 0.0...1.0),
                                       y: .random(in: (-100)..<(-20)))
  
  public var isAnimating: Bool = false
  public var isFalling: Bool = false
}

public class ConfettiModel {
  var isFalling: Bool = false
}

public struct ConfettiView: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @State private var particles: [ConfettiParticle] = []
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .topLeading) {
        ForEach(particles) { particle in
          particle.color
            .frame(width: particle.size.width, height: particle.size.height)
            .rotation3DEffect(.degrees(particle.isAnimating ? 360 : 0), axis: (x: particle.spinDirX, y: 0, z: 0))
            .animation(.linear(duration: particle.xSpeed).repeatCount(10, autoreverses: false).delay(particle.delay), value: particle.isAnimating)
            .rotation3DEffect(.degrees(particle.isAnimating ? 360 : 0), axis: (x: 0, y: 0, z: particle.spinDirZ),
                              anchor: UnitPoint(x: particle.anchor, y: particle.anchor))
            .animation(.linear(duration: particle.zSpeed).repeatForever(autoreverses: false), value: particle.isAnimating)
            .offset(x: particle.offset.x * geometry.size.width, y: particle.offset.y)
            .offset(y: particle.isFalling ? geometry.size.height + 110 : 0)
            .animation(.linear(duration: .random(in: 4...6)).delay(particle.delay), value: particle.isFalling)
          //            .transition(.asymmetric(insertion: .identity, removal: .opacity.animation(.easeInOut(duration: 0.5))))
        }
      }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
        .task {
          do {
            while windowModel.isShowingConfetti {
              particles.append(contentsOf: (0..<18).map { i in
                ConfettiParticle(delay: TimeInterval(i) * 0.06)
              })
              try await Task.sleepForOneFrame()
              particles.indices.forEach {
                if !particles[$0].isAnimating {
                  particles[$0].isAnimating = true
                }
              }
              try await Task.sleepForOneFrame()
              particles.indices.forEach {
                if !particles[$0].isFalling {
                  particles[$0].isFalling = true
                }
              }
              try await Task.sleep(seconds: 1)
              Task {
                try await Task.sleep(seconds: 6.1)
                particles.removeFirst(18)
              }
            }
          } catch {
            
          }
        }
    }.compositingGroup()
      .transaction { $0.animation = nil }
      .allowsHitTesting(false)
  }
}


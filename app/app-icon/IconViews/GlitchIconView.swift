import SwiftUI

import HelloCore

fileprivate struct BaseGlitchIconView: View {
  let characterView: AnyView
  
  public init<CharacterView: View>(characterView: CharacterView) {
    self.characterView = AnyView(characterView)
  }
  
  var offset: CGFloat {
    0.0175
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        Color(.sRGB, red: 0.05, green: 0.05, blue: 1, opacity: 1)
          .mask(characterView)
          .offset(x: -1.5 * offset * geometry.size.width, y: -offset * geometry.size.height)
        Color(.sRGB, red: 0.05, green: 1, blue: 0.05, opacity: 1)
          .mask(characterView)
          .offset(x: offset * geometry.size.width, y: offset * geometry.size.height)
        Color(.sRGB, red: 1, green: 0.05, blue: 0.05, opacity: 1)
          .mask(characterView)
          .offset(x: offset * geometry.size.width, y: -1.75 * offset * geometry.size.height)
        characterView
          .offset(x: -offset * geometry.size.width, y: -offset * geometry.size.height)
          .mask(characterView
                  .offset(x: offset * geometry.size.width, y: offset * geometry.size.height))
          .mask(characterView
                  .offset(x: 0.5 * offset * geometry.size.width, y: -offset * geometry.size.height))
      }.frame(width: geometry.size.width, height: geometry.size.height)
        .drawingGroup()
    }
  }
}

public struct GlitchIconView: View {
  
  private class NonObserved {
    var size: CGFloat = 0
  }
  
  let characterView: AnyView
  
  public init<CharacterView: View>(characterView: CharacterView) {
    self.characterView = AnyView(characterView)
  }
  
  @State private var nonObserved = NonObserved()
  @State var image: NativeImage?
  
  func update(size: CGFloat) {
    guard nonObserved.size != size else { return }
    nonObserved.size = size
    Task {
      if let image = ImageRendererer.render(view: BaseGlitchIconView(characterView: characterView),
                                          size: CGSize(width: size, height: size)) {
        self.image = image
      }
    }
  }
  
  struct GlitchSegment: Identifiable {
    var id: String = UUID().uuidString
    var height: CGFloat
    var offset: CGFloat
  }
  
  @State var segments: [GlitchSegment] = [
    GlitchSegment(height: 0.1, offset: 0),
    GlitchSegment(height: 0.05, offset: -0.025),
    GlitchSegment(height: 0.03, offset: 0.04),
    GlitchSegment(height: 0.04, offset: 0),
    GlitchSegment(height: 0.03, offset: 0.02),
    GlitchSegment(height: 0.06, offset: -0.02),
    GlitchSegment(height: 0.02, offset: -0.1),
    GlitchSegment(height: 0.07, offset: 0.01),
    GlitchSegment(height: 0.1, offset: 0),
    GlitchSegment(height: 0.04, offset: -0.025),
    GlitchSegment(height: 0.02, offset: -0.035),
    GlitchSegment(height: 0.025, offset: 0),
    GlitchSegment(height: 0.015, offset: -0.015),
    GlitchSegment(height: 0.02, offset: 0),
    GlitchSegment(height: 0.05, offset: 0.02),
    GlitchSegment(height: 0.03, offset: -0.02),
    GlitchSegment(height: 0.01, offset: 0.1),
    GlitchSegment(height: 0.04, offset: -0.04),
    GlitchSegment(height: 0.05, offset: -0.01),
    GlitchSegment(height: 0.01, offset: 0),
    GlitchSegment(height: 0.06, offset: -0.02),
    GlitchSegment(height: 0.03, offset: 0.04),
    GlitchSegment(height: 0.04, offset: 0.01),
    GlitchSegment(height: 0.06, offset: 0)
  ]
  
  func yOffset(for segmentID: String) -> CGFloat {
    var offset: CGFloat = 0
    for segment in segments {
      if segment.id == segmentID {
        return offset
      } else {
        offset += segment.height
      }
    }
    return offset
  }
  
  public var body: some View {
    GeometryReader { geometry in
      var _ = update(size: geometry.size.minSide)
      ZStack {
        ForEach(segments) { segment in
          Group {
            if let image = image {
              Image(nativeImage: image)
            } else {
              BaseGlitchIconView(characterView: characterView)
                .frame(width: geometry.size.width,
                       height: geometry.size.height)
            }
          }
            .mask {
              Rectangle()
                .frame(width: geometry.size.width,
                       height: segment.height * geometry.size.height)
                .offset(y: yOffset(for: segment.id) * geometry.size.height)
                .frame(width: geometry.size.width,
                       height: geometry.size.height,
                       alignment: .top)
            }
            .offset(x: segment.offset * geometry.size.width)
        }
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
      .background(HelloColor.black.swiftuiColor)
      .drawingGroup()
    }
  }
}

#if os(macOS)
import AVKit
import SwiftUI

public struct VideoView: NativeViewRepresentable {
  
  public typealias NSViewType = AVPlayerView
  
  private var player: AVPlayer
  
  public init(player: AVPlayer) {
    self.player = player
  }
  
  public func makeView(context: Context) -> AVPlayerView {
    let view = AVPlayerView()
    view.controlsStyle = .none
    view.player = player
    view.videoGravity = .resizeAspectFill
    return view
  }
}
#endif

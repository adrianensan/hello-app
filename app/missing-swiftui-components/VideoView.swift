#if os(macOS)
import AVKit
import SwiftUI

public struct VideoView: NativeViewRepresentable {
  
  public typealias NSViewType = AVPlayerView
  
  private var player: AVPlayer
  private var allowControls: Bool
  
  public init(player: AVPlayer, allowControls: Bool = false) {
    self.player = player
    self.allowControls = allowControls
  }
  
  public func makeView(context: Context) -> AVPlayerView {
    let view = AVPlayerView()
    view.controlsStyle = allowControls ? .inline : .none
    view.player = player
    view.videoGravity = .resizeAspectFill
    return view
  }
}
#endif

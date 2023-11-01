import AVKit
import SwiftUI

#if os(macOS)
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
#elseif os(iOS) || os(tvOS)
public struct VideoView: UIViewControllerRepresentable {
  
  private var player: AVPlayer
  private var allowControls: Bool
  
  public init(player: AVPlayer, allowControls: Bool = false) {
    self.player = player
    self.allowControls = allowControls
  }
  
  public func makeUIViewController(context: Context) -> some UIViewController {
    let controller = AVPlayerViewController()
    controller.player = player
    controller.showsPlaybackControls = allowControls
    controller.videoGravity = .resizeAspectFill
    return controller
  }
  
  public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    
  }
}
#endif

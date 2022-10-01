import SwiftUI
import AVFoundation

public class NativeCameraPreviewView: NativeView {
  
  #if os(iOS)
  public override static var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
  #elseif os(macOS)
  public override func makeBackingLayer() -> CALayer {
    AVCaptureVideoPreviewLayer()
  }
  #endif
  
  
  var session: AVCaptureSession? {
    get { previewLayer.session }
    set { previewLayer.session = newValue }
  }
  
  var previewLayer: AVCaptureVideoPreviewLayer {
    #if os(macOS)
    if layer == nil {
      wantsLayer = true
    }
    #endif
    return layer as! AVCaptureVideoPreviewLayer
  }
}

public protocol CaptureModel: ObservableObject {
  var captureSession: AVCaptureSession { get async }
}

public struct CameraPreviewView<Model: CaptureModel>: NativeViewRepresentable {
  
  public typealias UIViewType = NativeCameraPreviewView
  public typealias NSViewType = NativeCameraPreviewView
  
  @ObservedObject var model: Model
  
  public init(model: Model) {
    self.model = model
  }
  
  public func makeView(context: Context) -> NativeCameraPreviewView {
    let view = NativeCameraPreviewView()
    let layer = view.previewLayer
    
    layer.videoGravity = .resizeAspectFill
    
    Task {
      layer.session = await model.captureSession
      layer.connection?.automaticallyAdjustsVideoMirroring = false
      layer.connection?.isVideoMirrored = true
    }
    return view
  }
  
  public static func dismantleView(_ view: NativeCameraPreviewView, coordinator: ()) {
    let layer = view.previewLayer
    layer.removeFromSuperlayer()
  }
  
  public func updateView(_ view: NativeCameraPreviewView, context: Context) {
    view.previewLayer.videoGravity = .resizeAspectFill
    view.previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
    view.previewLayer.connection?.isVideoMirrored = true
  }
}

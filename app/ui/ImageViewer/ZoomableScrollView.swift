#if os(iOS)
import SwiftUI

import HelloCore

//class PencilDelegate: NSObject, UIPencilInteractionDelegate {
//
//  static var main: PencilDelegate = PencilDelegate()
//
//  func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
//    if GameInteractionModel.main.isFlaggingModeAvailable {
//      GameInteractionModel.main.isFlaggingMode.toggle()
//    }
//  }
//}

struct ZoomScrollView<Content: View>: UIViewRepresentable {
  
  class ZoomScrollViewCoordinator: NSObject, UIScrollViewDelegate {
    
    var hostingController: UIHostingController<Content>
    lazy var widthConstraint: NSLayoutConstraint = hostingController.view.widthAnchor.constraint(equalToConstant: 0)
    lazy var heightConstraint: NSLayoutConstraint = hostingController.view.heightAnchor.constraint(equalToConstant: 0)
    
    private var onDismiss: (CGPoint) -> Void
    private var onMaxDismissReached: (CGPoint) -> Void
    private var dismissOffset: CGPoint?
    
    init(hostingController: UIHostingController<Content>,
         onDismiss: @escaping (CGPoint) -> Void,
         onMaxDismissReached: @escaping (CGPoint) -> Void) {
      self.hostingController = hostingController
      self.onDismiss = onDismiss
      self.onMaxDismissReached = onMaxDismissReached
      super.init()
      widthConstraint.isActive = true
      heightConstraint.isActive = true
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      hostingController.view
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
      false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      if let dismissOffset {
//        if scrollView.contentOffset.magnitude > dismissOffset.magnitude {
//          self.dismissOffset = scrollView.contentOffset
//        } else {
          scrollView.contentOffset = dismissOffset
          onMaxDismissReached(dismissOffset)
//        }
      }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
      if scrollView.zoomScale == 1 && velocity.magnitude > 1 {
        dismissOffset = scrollView.contentOffset
        onDismiss(velocity)
      }
    }
  }
  
  @EnvironmentObject private var uiProperties: UIProperties
  
  private var contentSize: CGSize
  private var content: Content
  private var onDismiss: (CGPoint) -> Void
  private var onMaxDismissReached: (CGPoint) -> Void
  
  init(size: CGSize,
       onDismiss: @escaping (CGPoint) -> Void,
       onMaxDismissReached: @escaping (CGPoint) -> Void,
       @ViewBuilder content: () -> Content) {
    self.contentSize = size
    self.onDismiss = onDismiss
    self.onMaxDismissReached = onMaxDismissReached
    self.content = content()
  }
  
  func makeUIView(context: Context) -> UIScrollView {
    let scrollView = UIScrollView() +& {
      $0.delegate = context.coordinator
      $0.maximumZoomScale = 3
      $0.delaysContentTouches = true
      $0.showsVerticalScrollIndicator = false
      $0.showsHorizontalScrollIndicator = false
      $0.scrollsToTop = false
      $0.decelerationRate = .fast
    }
    
    let subView: UIView = context.coordinator.hostingController.view
//    subView.addInteraction(UIPencilInteraction() +& { $0.delegate = PencilDelegate.main })
    subView.backgroundColor = .clear
    subView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(subView)
    NSLayoutConstraint.activate([
      subView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      subView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      subView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      subView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
    ])
    return scrollView
  }
  
  func makeCoordinator() -> ZoomScrollViewCoordinator {
    ZoomScrollViewCoordinator(hostingController: UIHostingController(rootView: content),
                              onDismiss: onDismiss,
                              onMaxDismissReached: onMaxDismissReached)
  }
  
  func updateUIView(_ uiView: UIScrollView, context: Context) {
    let edgeInsets = UIEdgeInsets(top: 0.5 * uiProperties.size.height,
                                  left: 0.5 * uiProperties.size.width,
                                  bottom: 0.35 * uiProperties.size.height,
                                  right: 0.5 * uiProperties.size.width)
    
    context.coordinator.hostingController.rootView = content
    context.coordinator.widthConstraint.constant = contentSize.width
    context.coordinator.heightConstraint.constant = contentSize.height
    uiView.alwaysBounceVertical = true
    uiView.alwaysBounceHorizontal = true
    uiView.contentSize = contentSize
    uiView.minimumZoomScale = 1
//    uiView.contentInset = edgeInsets
    uiView.contentOffset = CGPoint(x: 0.5 * (contentSize.width - uiProperties.size.width),
                                   y: 0.5 * (contentSize.height - uiProperties.size.height))
  }
}
#endif

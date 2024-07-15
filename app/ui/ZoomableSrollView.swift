#if os(iOS)
import SwiftUI

struct ZoomableSrollView<Content: View>: UIViewRepresentable {
  
  class Coordinator: NSObject, UIScrollViewDelegate {
    
    var hostingController: UIHostingController<Content>
    lazy var widthConstraint: NSLayoutConstraint = hostingController.view.widthAnchor.constraint(equalToConstant: 0)
    lazy var heightConstraint: NSLayoutConstraint = hostingController.view.heightAnchor.constraint(equalToConstant: 0)
    
    init(hostingController: UIHostingController<Content>) {
      self.hostingController = hostingController
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
  }
  
  private var contentSize: CGSize
  private var content: Content
  
  init(size: CGSize, @ViewBuilder content: () -> Content) {
    self.contentSize = size
    self.content = content()
  }
  
  func makeUIView(context: Context) -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.delegate = context.coordinator
    scrollView.maximumZoomScale = 3
    scrollView.delaysContentTouches = true
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.scrollsToTop = false
    scrollView.decelerationRate = .fast
    
    let subView: UIView = context.coordinator.hostingController.view
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
  
  func makeCoordinator() -> Coordinator {
    Coordinator(hostingController: UIHostingController(rootView: content))
  }
  
  func updateUIView(_ uiView: UIScrollView, context: Context) {
    context.coordinator.hostingController.rootView = content
    context.coordinator.widthConstraint.constant = contentSize.width
    context.coordinator.heightConstraint.constant = contentSize.height
    uiView.alwaysBounceVertical = true
    uiView.alwaysBounceHorizontal = true
    uiView.contentSize = contentSize
    uiView.minimumZoomScale = 1
  }
}
#endif

//#if os(iOS)
//import SwiftUI
//import UIKit
//
//
//protocol UIViewSubClass: AnyObject {
//}
//
//extension UIViewSubClass where Self: UIView {
//  func hitTextReal(_ point: CGPoint, with event: UIEvent?) {
//    super.hitTest(point, with: event)
//  }
//}
//
//public class CustomRootUIView<ViewType: View>: _UIHostingView<ViewType> {
//  
//  private func traverseView(uiView: UIView) {
//    for view in uiView.subviews {
//      traverseView(uiView: view)
//    }
////    print(uiView.button)
//  }
//  
//  public override func didMoveToWindow() {
//    Task {
//      try await Task.sleep(seconds: 2)
//      traverseView(uiView: self)
//    }
//  }
//  
//  func hitTestOverride(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//    let targetView = super.hitTest(point, with: event)
//    if let targetView, targetView.frame != self.frame {
//      return targetView
//    } else {
//      return nil
//    }
//  }
//}
//
//public class CustomRootViewController2<ViewType: View>: UIHostingController<ViewType> {
//  
//  let rootSwiftUIView: ViewType
//  
//  public override func loadView() {
//    view = CustomRootUIView(rootView: rootSwiftUIView)
//  }
//  
//  public init(wrappedView: ViewType) {
//    rootSwiftUIView = wrappedView
//    super.init(rootView: wrappedView)
//  }
//  
//  @available(*, unavailable)
//  required init?(coder aDecoder: NSCoder) {
//    fatalError("Unavailable")
//  }
//}
//#endif
//
//public class CustomRootViewController<ViewType: View>: UIHostingController<ViewType> {
//  
//  public init(wrappedView: ViewType) {
//    super.init(rootView: wrappedView)
//    changeViewType()
//  }
//  
//  @available(*, unavailable)
//  required init?(coder aDecoder: NSCoder) {
//    fatalError("Unavailable")
//  }
//  
//  func changeViewType() {
//    guard let viewClass = object_getClass(view) else { return }
//    
//    let viewSubclassName = String("CustomRootUIHostingView")
//    guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
//    guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
//    
//    if let method = class_getInstanceMethod(viewClass, #selector(UIView.hitTest)) {
//      let hitTestBlock: @convention(block) (CGPoint, UIEvent?) -> UIView? = {
//        self.hitTestOverride($0, with: $1)
//      }
//      class_addMethod(viewSubclass, #selector(UIView.hitTest),
//                      imp_implementationWithBlock(hitTestBlock),
//                      method_getTypeEncoding(method))
//    }
//    
//    objc_registerClassPair(viewSubclass)
//    object_setClass(view, viewSubclass)
//  }
//  
//  func hitTestOverride(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//    view
//    let targetView = super.hitTest(point, with: event)
//    if let targetView, targetView.frame != self.frame {
//      return targetView
//    } else {
//      return nil
//    }
//  }
//}

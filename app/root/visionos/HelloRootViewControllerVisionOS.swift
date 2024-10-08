#if os(visionOS)
import SwiftUI
import UIKit

import HelloCore

@MainActor
public class HelloRootViewController: UIHostingController<AnyView> {
  
  var uiProperties: UIProperties
  var windowModel: HelloWindowModel
  
  public init<T: View>(window: UIWindow? = nil, wrappedView: @escaping @MainActor () -> T) {
    //    let uiProperties = UIProperties(initialSize: .zero, initialSafeArea: .zero)
    uiProperties = UIProperties(initialSize: window?.frame.size ?? .zero, initialSafeArea: window?.safeAreaInsets ?? .zero)
    windowModel = HelloWindowModel()
    windowModel.window = window
    let id = HelloUUID().string
    let observedView = AnyView(HelloAppRootView(wrappedView)
      .environment(uiProperties)
      .environment(windowModel)
      .ignoresSafeArea())
    
    super.init(rootView: observedView)
//    disableKeyboardOffset()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("Unavailable")
  }
  
  func disableKeyboardOffset() {
    guard let viewClass = object_getClass(view) else { return }
    
    let viewSubclassName = String("HelloRootUIHostingView")
    guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
    guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
    
    if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
      let safeAreaInsets: @convention(block) () -> UIEdgeInsets = { .zero }
      class_addMethod(viewSubclass,
                      #selector(getter: UIView.safeAreaInsets),
                      imp_implementationWithBlock(safeAreaInsets),
                      method_getTypeEncoding(method))
    }
    
    objc_registerClassPair(viewSubclass)
    object_setClass(view, viewSubclass)
  }
  
  func updateSize() {
    let size = view.bounds.size
    guard size.minSide > 0 else { return }
    uiProperties.updateSize(to: size)
    if let safeArea = view.window?.safeAreaInsets {
      uiProperties.updateSafeAreaInsets(to: safeArea)
    }
  }
  
  //  override var prefersHomeIndicatorAutoHidden: Bool {
  //    hideHomeIndicator
  //  }
  
  override public func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    updateSize()
  }
  
  override public func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateSize()
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateSize()
  }
  
  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateSize()
  }
  
  override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    updateSize()
  }
  
  override public func viewWillTransition(to size: CGSize,
                                          with coordinator: any UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    updateSize()
  }
  
  override public func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    updateSize()
  }
  
  override public func updateViewConstraints() {
    super.updateViewConstraints()
    updateSize()
  }
  
  override public var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
    .hidden
  }
}
#endif

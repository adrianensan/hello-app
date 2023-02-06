#if os(iOS)
import Foundation
import SwiftUI
import UIKit
import SwiftConvenience

struct StatusBarStyleKey: PreferenceKey {
  static var defaultValue: UIStatusBarStyle = .default
  
  static func reduce(value: inout UIStatusBarStyle, nextValue: () -> UIStatusBarStyle) {
    value = nextValue()
  }
}

public extension View {
  func statusBar(nativeStyle: UIStatusBarStyle) -> some View {
    preference(key: StatusBarStyleKey.self, value: nativeStyle)
  }
}

struct HomeIndicatorHiddenKey: PreferenceKey {
  static var defaultValue: Bool = false
  
  static func reduce(value: inout Bool, nextValue: () -> Bool) {
    value = nextValue()
  }
}

public extension View {
  func homeIndicator(hidden: Bool) -> some View {
    preference(key: HomeIndicatorHiddenKey.self, value: hidden)
  }
}

struct LockOrientationKey: PreferenceKey {
  static var defaultValue: Bool = false
  
  static func reduce(value: inout Bool, nextValue: () -> Bool) {
    value = nextValue()
  }
}

public extension View {
  func lockOrientation(_ lockOrientation: Bool) -> some View {
    preference(key: LockOrientationKey.self, value: lockOrientation)
  }
}

@available(iOSApplicationExtension, unavailable)
public class HelloRootViewController: UIHostingController<AnyView> {
  
  var statusBarStyle: UIStatusBarStyle = .default
  var lockRotation: Bool = false
  var hideHomeIndicator: Bool = false
  public var onBrightnessChange: (() -> Void)?
  
  public init<T: View>(wrappedView: T) {
    UIConstantsObservable.main.safeAreaInsets = (UIApplication.shared.windows.first?.safeAreaInsets ?? .zero) =& {
      EdgeInsets(top: $0.top, leading: $0.left, bottom: $0.bottom, trailing: $0.right)
    }
    let observedView = AnyView(wrappedView
      .environmentObject(UIConstantsObservable.main)
      .onPreferenceChange(StatusBarStyleKey.self) { style in
        guard let viewController = Self.main,
              viewController.statusBarStyle != style else { return }
        viewController.statusBarStyle = style
        viewController.setNeedsStatusBarAppearanceUpdate()
      }.onPreferenceChange(HomeIndicatorHiddenKey.self) { hideHomeIndicator in
        guard let viewController = Self.main,
              viewController.hideHomeIndicator != hideHomeIndicator else { return }
        viewController.hideHomeIndicator = hideHomeIndicator
        viewController.setNeedsUpdateOfHomeIndicatorAutoHidden()
        viewController.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
      }.onPreferenceChange(LockOrientationKey.self) { lockRotation in
        guard let viewController = Self.main,
              viewController.lockRotation != lockRotation else { return }
        viewController.lockRotation = lockRotation
        if lockRotation && Hello.window.windowScene?.interfaceOrientation != .portrait {
          UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        }
        UIViewController.attemptRotationToDeviceOrientation()
      }.ignoresSafeArea())
    
    super.init(rootView: observedView)
    Self.main = self
    view.backgroundColor = .black
    disableKeyboardOffset()
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(brightnessDidChange),
                                           name: UIScreen.brightnessDidChangeNotification,
                                           object: nil)
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("Unavailable")
  }
  
  func disableKeyboardOffset() {
    guard let viewClass = object_getClass(view) else { return }
    
    let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoresKeyboard")
    if let viewSubclass = NSClassFromString(viewSubclassName) {
      object_setClass(view, viewSubclass)
    }
    else {
      guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
      guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
      
      if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
        let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
          return .zero
        }
        class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
      }
      
      if let method = class_getInstanceMethod(viewClass, NSSelectorFromString("keyboardWillShowWithNotification:")) {
        let keyboardWillShow: @convention(block) (AnyObject, AnyObject) -> Void = { _, _ in }
        class_addMethod(viewSubclass, NSSelectorFromString("keyboardWillShowWithNotification:"),
                        imp_implementationWithBlock(keyboardWillShow), method_getTypeEncoding(method))
      }
      
      objc_registerClassPair(viewSubclass)
      object_setClass(view, viewSubclass)
    }
  }
  
  override public var preferredStatusBarStyle: UIStatusBarStyle {
    statusBarStyle
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
                                          with coordinator: UIViewControllerTransitionCoordinator) {
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
  
  override public var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
    return hideHomeIndicator ? [.bottom] : []
  }
  
  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    lockRotation ? .portrait : .allButUpsideDown
  }
  
  public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    .portrait
  }
  
  @objc func brightnessDidChange() {
    onBrightnessChange?()
  }
}

#endif

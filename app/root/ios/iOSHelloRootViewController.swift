#if os(iOS)
import SwiftUI
import UIKit

import HelloCore

struct StatusBarStyleKey: PreferenceKey {
  static let defaultValue: UIStatusBarStyle = .default
  
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
  static let defaultValue: Bool = false
  
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
  static let defaultValue: Bool = false
  
  static func reduce(value: inout Bool, nextValue: () -> Bool) {
    value = nextValue()
  }
}

public extension View {
  func lockOrientation(_ lockOrientation: Bool) -> some View {
    preference(key: LockOrientationKey.self, value: lockOrientation)
  }
}

@MainActor
public class HelloRootViewController: UIHostingController<AnyView> {
  
  var lockRotation: Bool = false
  var hideHomeIndicator: Bool = false
  public var onBrightnessChange: (() -> Void)?
  
  var uiProperties: UIProperties
  var windowModel: HelloWindowModel
  
  public init<T: View>(window: UIWindow? = nil, windowCornerRadius: CGFloat = 0, wrappedView: T) {
//    let uiProperties = UIProperties(initialSize: .zero, initialSafeArea: .zero)
    uiProperties = UIProperties(initialSize: window?.frame.size ?? .zero, initialSafeArea: window?.safeAreaInsets ?? .zero)
    windowModel = HelloWindowModel()
    windowModel.update(colorScheme: UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .dark : .light)
    windowModel.window = window
//      .onPreferenceChange(HomeIndicatorHiddenKey.self) { hideHomeIndicator in
//        guard let viewController = Self.instances[id],
//              viewController.hideHomeIndicator != hideHomeIndicator else { return }
//        viewController.hideHomeIndicator = hideHomeIndicator
//        viewController.setNeedsUpdateOfHomeIndicatorAutoHidden()
//        viewController.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
//      }.onPreferenceChange(LockOrientationKey.self) { lockRotation in
//        guard let viewController = Self.instances[id],
//              viewController.lockRotation != lockRotation else { return }
//        viewController.lockRotation = lockRotation
//        
//        //window.windowScene?.interfaceOrientation != .portrait
//        if lockRotation {
//          UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
//        }
//        UIViewController.attemptRotationToDeviceOrientation()
//      }
      
    super.init(rootView: AnyView(HelloAppRootView { wrappedView }
      .environment(uiProperties)
      .environment(windowModel)
      .environment(\.windowCornerRadius, windowCornerRadius)
      .ignoresSafeArea()))
//    view.backgroundColor = .black
    disableKeyboardAvoidance()
    
    registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection) in
      self.windowModel.update(colorScheme: UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .dark : .light)
    }
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(brightnessDidChange),
                                           name: UIScreen.brightnessDidChangeNotification,
                                           object: nil)
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("Unavailable")
  }
  
  // There is built in keyboard avoidance starting from iOS 14, it's horrifying.
  // Any UIHostingController will be shifted up automatically, with no way to disable it.
  // Even small views in a list might get individually shifted up for no reason.
  // This behvaiour almost always results in buggy behvaiour when using UIHostingController,
  // and only works alright when using the SwfitUI App lifecycle, with no safe area management.
  //
  // The following disables this keyboard offset behaviour, we can manage safe area and offsets ourselves.
  private func disableKeyboardAvoidance() {
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
    
    let keyboardWillShowSelector = NSSelectorFromString("keyboardWillShowWithNotification:")
    if let method = class_getInstanceMethod(viewClass, keyboardWillShowSelector) {
      let keyboardWillShowBlock: @convention(block) (AnyObject, AnyObject) -> Void = { _, _ in }
      class_addMethod(viewSubclass,
                      keyboardWillShowSelector,
                      imp_implementationWithBlock(keyboardWillShowBlock),
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
  
  override public func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
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
//    [.all]
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

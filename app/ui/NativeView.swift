import SwiftUI

#if canImport(UIKit)
public typealias NativeView = UIView
#elseif canImport(AppKit)
public typealias NativeView = NSView
#endif

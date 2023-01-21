import SwiftUI

#if os(watchOS)
public typealias NativeView = View
#elseif canImport(UIKit)
public typealias NativeView = UIView
#elseif canImport(AppKit)
public typealias NativeView = NSView
#endif

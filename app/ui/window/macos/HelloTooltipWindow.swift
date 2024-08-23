#if os(macOS)
import SwiftUI

import HelloCore

public class HelloTooltipWindow: HelloWindow {
  
  private var anchor: WindowAnchor
  
  private var targetOrigin: CGPoint {
    var target = anchor.point - nsWindow.frame.size
    switch anchor.alignment.horizontal {
    case .center: target.x += 0.5 * nsWindow.frame.size.width
    case .leading: target.x += nsWindow.frame.size.width
    default: ()
    }
    
    switch anchor.alignment.vertical {
    case .center: target.y += 0.5 * nsWindow.frame.size.height
    case .bottom: target.y += nsWindow.frame.size.height
    default: ()
    }
    return target
  }
  
  public init(id: String = .uuid, anchor: WindowAnchor, content: @autoclosure () -> some View) {
    self.anchor = anchor
    super.init(view: content(),
               id: id,
               size: .fixedAuto,
               windowFlags: [.borderless],
               isPanel: true)
    draggableArea = .none
    nsWindow.ignoresMouseEvents = true
    nsWindow.collectionBehavior = [.transient, .ignoresCycle, .stationary]
    nsWindow.level = .statusBar
    nsWindow.backgroundColor = .clear
    nsWindow.isOpaque = false
  }
  
  override public func show() {
    nsWindow.orderFrontRegardless()
  }
  
  override public func onResize() {
    if nsWindow.frame.origin != targetOrigin {
      nsWindow.setFrameOrigin(targetOrigin)
    }
  }
  
  override public func onMove() {
    if nsWindow.frame.origin != targetOrigin {
      nsWindow.setFrameOrigin(targetOrigin)
    }
  }
}

struct HelloTooltipView<Content: View>: View {
  
  @Environment(\.theme) var theme
  
  var content: Content
  
  init(content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    content
      .fixedSize()
      .font(.system(size: 14, weight: .regular, design: .default))
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(theme.backgroundView(for: RoundedRectangle(cornerRadius: 12, style: .continuous), isBaseLayer: false))
      .compositingGroup()
      .shadow(color: .black.opacity(0.1), radius: 4, y: 1)
      .padding(6)
  }
}

public enum TooltipTrigger: Equatable, Sendable {
  case onHover
  case onClick
}

@MainActor
fileprivate struct TooptipViewModifier<TooltipContent: View>: ViewModifier {
  
  @Environment(HelloWindowModel.self) private var windowModel
  
  @NonObservedState private var globalPosition: CGPoint = .zero
  @State private var id: String = .uuid
  
  var trigger: TooltipTrigger
  var content: () -> TooltipContent
  
  func showTooltip() {
    guard let windowFrame = windowModel.window?.frame else { return }
    var position = windowFrame.origin
    position.x += globalPosition.x
    position.y += windowFrame.height - globalPosition.y
    let tooltipWindow = HelloTooltipWindow(id: id,
                                           anchor: WindowAnchor(point: position, alignment: .bottom),
                                           content: HelloTooltipView { content() })
    windowModel.window?.show(temporaryWindow: tooltipWindow)
//    windowModel.window?.show(temporarySubView: HelloTooltipView { content() },
//                             at: position,
//                             alignment: .bottom,
//                             id: id)
  }
  
  func body(content: Content) -> some View {
    content
      .readFrame { globalPosition = $0.top }
      .onTapGesture {
        if trigger == .onClick {
          showTooltip()
        }
      }
      .onHover {
        if $0 {
          if trigger == .onHover {
            showTooltip()
          }
        } else if windowModel.window?.temporaryWindowID == id {
          windowModel.window?.closeTemporaryWindow()
        }
      }.onDisappear { 
        if windowModel.window?.temporaryWindowID == id {
          windowModel.window?.closeTemporaryWindow()
        }
      }
  }
}

@MainActor
public extension View {
  func helloTooltip(trigger: TooltipTrigger = .onHover,
                    @ViewBuilder view: @escaping () -> some View) -> some View {
    self.modifier(TooptipViewModifier(trigger: trigger, content: view))
  }
}
#endif

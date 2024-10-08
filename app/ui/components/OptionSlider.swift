import SwiftUI

import HelloCore

public protocol OptionSliderElement: Hashable, Sendable, Identifiable {
  
  associatedtype Body: View
  
  @MainActor
  var view: Body { get }
}

public struct OptionSlider<T: OptionSliderElement>: View {
  
  @Environment(\.theme) private var theme
  
  private let segmentSize: CGFloat = 36//{ width / CGFloat(options.count) }
  @Binding private var selectedValue: T
  @State private var optionFrames: [T: CGRect] = [:]
  private var options: [T]
  private var onChange: ((T) -> Void)? = nil
  
  public init(selectedValue: Binding<T>,
       options: [T],
       onChange: ((T) -> Void)? = nil) {
    _selectedValue = selectedValue
    self.options = options
    self.onChange = onChange
  }
  
  var drag: some Gesture {
    DragGesture(minimumDistance: 1)
      .onChanged { drag in
        guard let option = optionFrames.first(where: { $1.minX < drag.location.x && $1.maxX > drag.location.x }) else { return }
//        var segment: Int = Int($0.location.x / segmentSize)
//        segment = min(segment, options.count - 1)
//        segment = max(0, segment)
        select(option.key)
      }
  }
  
  func select(_ newValue: T) {
    guard selectedValue != newValue else { return }
    Haptics.buttonFeedback()
    withAnimation(.ddampSpring) {
      selectedValue = newValue
    }
    onChange?(newValue)
  }
  
  func frame(for option: T) -> CGRect {
    optionFrames[option] ?? CGRect(x: 0, y: 0, width: 40, height: 40)
  }
  
  var selectedWidth: CGFloat {
    frame(for: selectedValue).width
  }
  
  public var body: some View {
    ZStack(alignment: .leading) {
      Capsule()
        .fill(theme.accent.style)
        .frame(width: max(40, selectedWidth), height: 40)
        .overlay(Capsule().stroke(theme.surfaceSection.foreground.primary.color.opacity(0.1), lineWidth: 1))
        .frame(height: 36)
        .offset(x: frame(for: selectedValue).minX - 0.5 * max(0, 40 - selectedWidth))
      HStack(spacing: 0) {
        ForEach(options) { option in
          option.view
            .font(.system(size: 13, weight: .medium))
            .frame(minWidth: 40)
            .foregroundStyle(selectedValue == option ? theme.accent.readableOverlayColor : theme.surfaceSection.foreground.primary.color)
            .scaleEffect(selectedValue == option ? 1.16 : 1)
            .readFrame(in: .named("slider")) {
              guard optionFrames[option] != $0 else { return }
              optionFrames[option] = $0
            }
            .clickable()
            .onTapGesture {
              select(option)
            }
        }
      }.frame(height: 36)
      ClearClickableView()
        .frame(width: frame(for: selectedValue).width, height: 40)
        .frame(height: 36)
        .offset(x: frame(for: selectedValue).minX)
        .gesture(drag)
    }.coordinateSpace(name: "slider")
      .background(theme.surfaceSection.backgroundView(for: Capsule(style: .continuous)))
      .animation(.dampSpring, value: selectedValue)
  }
}

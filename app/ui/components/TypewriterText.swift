import SwiftUI

import HelloCore

public struct TypewriterText: View {
  
  @State private var timer = Timer.publish(every: 0.016, tolerance: 0.01, on: .main, in: .common).autoconnect()
  @State private var appearedText: String = ""
  @State private var hiddenText: String = ""
  
  var text: String
  var appear: Bool
  var forceInstant: Bool = false
  
  public init(_ text: String, appear: Bool = true, forceInstant: Bool = false) {
    self.text = text
    self.appear = appear
    self.forceInstant = forceInstant
    _appearedText = State(initialValue: "")
    _hiddenText = State(initialValue: text)
  }
  
  public var body: some View {
    (Text(appearedText)
     + Text(hiddenText).foregroundColor(Color.clear))
    .opacity(appear || appearedText.isEmpty ? 1 : 0)
    .onChange(of: text) {
      appearedText = ""
      hiddenText = $0
      timer.upstream.connect().cancel()
      timer = Timer.publish(every: 0.016, tolerance: 0.01, on: .main, in: .common).autoconnect()
    }.onChange(of: appear) {
      if $0 {
        appearedText = ""
        hiddenText = text
        timer = Timer.publish(every: 0.016, tolerance: 0.01, on: .main, in: .common).autoconnect()
      } else {
        timer.upstream.connect().cancel()
      }
    }.onReceive(timer) { _ in
      if forceInstant {
        appearedText.append(hiddenText)
        hiddenText = ""
      }
      guard appear, let nextChar = hiddenText.first else {
        timer.upstream.connect().cancel()
        return
      }
      appearedText.append(nextChar)
      hiddenText.removeFirst()
    }
  }
}

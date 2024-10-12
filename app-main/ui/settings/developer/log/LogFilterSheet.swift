import SwiftUI

import HelloCore
import HelloApp

public struct LogContextFilter: Identifiable, HelloPickerItem {
  
  public var filter: String?
  
  public init(filter: String?) {
    self.filter = filter
  }
  
  public var id: String { filter ?? "none" }
  public var name: String { filter ?? "All" }
}

struct LogFilterSheet: View {
  
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.safeArea) private var safeArea
  @Environment(\.theme) private var theme
  @Environment(LoggerModel.self) private var logModel
  
  init() {}
  
  var body: some View {
    VStack(spacing: 0) {
      Text("Log Filters")
        .font(.system(size: 20, weight: .regular))
        .foregroundStyle(theme.foreground.primary.style)
        .fixedSize()
        .frame(height: 60)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      HelloSection {
        HelloNavigationRow(
          icon: "line.3.horizontal.decrease",
          name: "Filter",
          trailingContent: {
            HelloPicker(selected: LogContextFilter(filter: logModel.filter),
                        options: [LogContextFilter(filter: nil)] + logModel.filters.map(LogContextFilter.init),
                        onChange: { logModel.set(filter: $0.filter) })
          })
        
        HelloNavigationRow(
          icon: "apple.terminal",
          name: "Show Verbose Logs",
          description: "Including logs can be incredibly useful for diagnosing any issues you may be having.",
          trailingContent: {
            HelloToggle(isSelected: logModel.showVerbose, action: { logModel.set(showVerbose: !logModel.showVerbose) })
          })
      }
    }.padding(.horizontal, 16)
      .padding(.bottom, safeArea.bottom + 16)
  }
}

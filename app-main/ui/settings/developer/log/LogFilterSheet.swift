#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct LogContextFilter: Identifiable, HelloPickerItem {
  
  public var filter: LogContext?
  
  public init(filter: LogContext?) {
    self.filter = filter
  }
  
  public var id: String { filter?.string ?? "none" }
  public var name: String { filter?.string ?? "All" }
}

struct LogFilterSheet: View {
  
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.safeArea) private var safeArea
  @Environment(\.theme) private var theme
  @Environment(LoggerModel.self) private var logModel
  
  init() {}
  
  var body: some View {
    HelloPage(title: "Log Filters", allowScroll: false) {
      VStack(spacing: 0) {
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
      }
    }
  }
}
#endif

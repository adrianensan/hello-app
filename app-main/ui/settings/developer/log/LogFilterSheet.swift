import SwiftUI

import HelloCore
import HelloApp

struct LogFilterSheet: View {
  
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.safeArea) private var safeArea
  @Environment(\.theme) private var theme
  @Environment(LoggerModel.self) private var logModel
  
  init() {
  }
  
  var body: some View {
    VStack(spacing: 0) {
      Text("Log Filters")
        .font(.system(size: 20, weight: .regular))
        .foregroundStyle(theme.foreground.primary.style)
        .fixedSize()
        .frame(height: 60)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      HelloSection {
        HelloSectionItem {
          VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
              Image(systemName: "apple.terminal")
                .font(.system(size: 20, weight: .regular))
                .frame(width: 32, height: 32)
              Text("Show Verbose Logs")
                .font(.system(size: 16, weight: .regular))
                .fixedSize()
              Spacer(minLength: 0)
              HelloToggle(isSelected: logModel.showVerbose, action: { logModel.set(showVerbose: !logModel.showVerbose) })
            }
            Text("Including logs can be incredibly useful for diagnosing any issues you may be having.")
              .font(.system(size: 13, weight: .regular))
              .foregroundStyle(theme.surface.foreground.tertiary.style)
              .fixedSize(horizontal: false, vertical: true)
              .padding(.leading, 36)
              .padding(.trailing, 64)
          }
        }
      }
    }.padding(.horizontal, 16)
      .padding(.bottom, safeArea.bottom + 16)
  }
}

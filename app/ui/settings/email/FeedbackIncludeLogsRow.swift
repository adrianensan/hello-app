import SwiftUI

import HelloCore

struct FeedbackIncludeLogsRow: View {
  
  @Environment(\.theme) private var theme
  
  @Binding var includeLogs: Bool
  
  var body: some View {
    HelloSectionItem {
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 4) {
          Image(systemName: "apple.terminal")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          Text("Include Logs")
            .font(.system(size: 16, weight: .regular))
            .fixedSize()
          Spacer(minLength: 0)
          HelloToggle(isSelected: includeLogs, action: { includeLogs.toggle() })
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
}

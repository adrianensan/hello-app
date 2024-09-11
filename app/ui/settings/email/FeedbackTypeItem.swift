#if os(iOS)
import SwiftUI

import HelloCore

extension FeedbackType: HelloPickerItem {}

struct FeedbackTypeItem: View {
  
  @Environment(\.theme) private var theme
  
  @Binding var type: FeedbackType
  
  var body: some View {
    HelloSectionItem {
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 4) {
          Image(systemName: "exclamationmark.bubble")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
            .offset(y: 2)
          Text("Type")
            .font(.system(size: 16, weight: .regular))
            .fixedSize()
          Spacer(minLength: 0)
          HelloPicker(selected: type,
                      options: FeedbackType.allCases,
                      onChange: { type = $0 })
        }
      }
    }
  }
}
#endif

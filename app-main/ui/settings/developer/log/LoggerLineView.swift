import SwiftUI

import HelloCore
import HelloApp

struct LoggerLineView: View {
  
  @Environment(\.theme) private var theme
  
  let logStatement: LogStatement
  
  @State private var isExpanded: Bool = false
  
  var backgroundColor: Color {
    switch logStatement.level {
    case .fatal, .wtf: return .red
    default: return .clear
    }
  }
  
  var symbolColor: Color {
    switch logStatement.level {
    case .meta: return .blue
    case .warning: return .yellow
    case .error, .fatal, .wtf: return .red
    case .debug: return .secondary.opacity(0.6)
    default: return .secondary
    }
  }
  
  var logColor: Color {
    switch logStatement.level {
    case .info, .meta, .warning, .error, .fatal, .wtf: theme.foreground.primary.color
    case .debug, .verbose: theme.foreground.tertiary.color
    }
  }
  
  var timeColor: Color {
    switch logStatement.level {
    case .fatal, .wtf: return .white
    default: return symbolColor
    }
  }
  
  var iconSize: CGFloat {
    #if os(macOS)
    11
    #else
    13
    #endif
  }
  
  var timeStampFontSize: CGFloat {
    #if os(macOS)
    9
    #else
    10
    #endif
  }
  
  var logFontSize: CGFloat {
    #if os(macOS)
    10
#else
    12
#endif
  }
  
  var body: some View {
    HelloButton(clickStyle: .highlight,
                action: { isExpanded.toggle() },
                longPressAction: .showMenu { @MainActor in [.copy(string: logStatement.formattedLine)] }) {
      HStack(alignment: isExpanded ? .top : .center, spacing: 6) {
        Image(systemName: logStatement.level.icon)
          .font(.system(size: iconSize, weight: .bold, design: .monospaced))
          .foregroundStyle(symbolColor)
          .frame(width: iconSize, height: iconSize)
        Text(isExpanded ? logStatement.fullTimeStampString : logStatement.shortimeStampString)
          .font(.system(size: timeStampFontSize, weight: .semibold, design: .monospaced))
          .foregroundStyle(timeColor)
          .fixedSize()
          .background(RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(backgroundColor))
        
        (Text(logStatement.context.map { $0.string + " "} ?? "").bold() +
         Text(isExpanded ? logStatement.message : logStatement.preview ?? logStatement.message))
          .font(.system(size: logFontSize, weight: .regular, design: .monospaced))
          .foregroundStyle(logColor)
          .lineLimit(isExpanded ? nil : 1)
          .fixedSize(horizontal: false, vertical: isExpanded)
      }.frame(height: isExpanded ? nil : 16)
        .fontDesign(.monospaced)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 16)
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
        .background(theme.backgroundColor)
    }
  }
}

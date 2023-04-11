import SwiftUI

import HelloCore

struct LoggerLineView: View {
  
  let logStatement: LogStatement
  
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
    HStack(alignment: .top, spacing: 2) {
      Image(systemName: logStatement.level.icon)
        .font(.system(size: iconSize, weight: .black, design: .rounded))
        .foregroundColor(symbolColor)
        .frame(width: iconSize, height: iconSize + 2)
      
      Text(logStatement.timeStampString)
        .font(.system(size: timeStampFontSize, weight: .semibold, design: .monospaced))
        .foregroundColor(timeColor)
        .frame(height: iconSize + 2)
        .padding(.horizontal, 2)
        .background(RoundedRectangle(cornerRadius: 4, style: .continuous)
          .fill(backgroundColor))
      
      #if os(iOS) || os(macOS)
      (Text("\(logStatement.context)").bold() + Text(" \(logStatement.message)"))
        .font(.system(size: logFontSize, weight: .regular, design: .monospaced))
        .foregroundColor(.primary)
        .textSelection(.enabled)
        .fixedSize(horizontal: false, vertical: true)
      #else
      (Text("\(logStatement.context)").bold() + Text(" \(logStatement.message)"))
        .font(.system(size: logFontSize, weight: .regular, design: .monospaced))
        .foregroundColor(.primary)
        .fixedSize(horizontal: false, vertical: true)
      #endif
    }
  }
}

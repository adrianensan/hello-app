import SwiftUI

import HelloCore

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
    HStack(alignment: .top, spacing: 2) {
      Image(systemName: logStatement.level.icon)
        .font(.system(size: iconSize, weight: .bold, design: .monospaced))
        .foregroundStyle(symbolColor)
        .frame(width: iconSize, height: iconSize + 2)
      
      Text(logStatement.timeStampString)
        .font(.system(size: timeStampFontSize, weight: .semibold, design: .monospaced))
        .foregroundStyle(timeColor)
        .frame(height: iconSize + 2)
        .padding(.horizontal, 2)
        .background(RoundedRectangle(cornerRadius: 4, style: .continuous)
          .fill(backgroundColor))
      
      #if os(iOS) || os(macOS)
      (Text(logStatement.context.map { $0 + " "} ?? "").bold() + Text(logStatement.message))
        .font(.system(size: logFontSize, weight: .regular, design: .monospaced))
        .foregroundStyle(logColor)
//        .textSelection(.enabled)
        .lineLimit(isExpanded ? nil : 1)
        .fixedSize(horizontal: false, vertical: isExpanded)
      #else
      ((logStatement.context.map { Text($0 + " ").bold() } ?? Text("")) + Text(logStatement.message))
        .font(.system(size: logFontSize, weight: .regular, design: .monospaced))
        .foregroundStyle(.primary)
        .fixedSize(horizontal: false, vertical: true)
      #endif
    }.frame(height: isExpanded ? nil : 16)
      .fontDesign(.monospaced)
      .frame(minHeight: 16)
      .clickable()
      .onTapGesture { isExpanded.toggle() }
  }
}

import SwiftUI

import HelloCore

struct LoggerLineView: View {
  
  let logStatement: LogStatement
  
  var color: Color {
    switch logStatement.level {
    case .warning: return .yellow
    case .error: return .red
    case .debug: return .secondary.opacity(0.6)
    default: return .secondary
    }
  }
  
  var body: some View {
    HStack(alignment: .top, spacing: 4) {
      Image(systemName: logStatement.level.icon)
        .font(.system(size: 13, weight: .black, design: .rounded))
        .foregroundColor(color)
        .frame(width: 13, height: 15)
      
      Text(logStatement.timeStampString)
        .font(.system(size: 10, weight: .semibold, design: .monospaced))
        .foregroundColor(color)
        .frame(height: 15)
      
      (Text("\(logStatement.context)").bold() + Text(" \(logStatement.message)"))
        .font(.system(size: 12, weight: .regular, design: .monospaced))
        .foregroundColor(.primary)
        .textSelection(.enabled)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

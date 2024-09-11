import SwiftUI

import HelloCore

public struct HelloVGrid<Content: View>: View {
  
  public enum Columns: Sendable {
    case fixed(Int)
  }
  
  @Environment(\.windowFrame) private var windowFrame
  
  private var columns: Columns
  private var alignment: HorizontalAlignment
  private var spacing: CGFloat
  @ViewBuilder private var content: @MainActor () -> Content
  
  public init(columns: Columns, alignment: HorizontalAlignment = .leading, spacing: CGFloat = 0, @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.columns = columns
    self.alignment = alignment
    self.spacing = spacing
    self.content = content
  }
  
  private var numberOfColumns: Int {
    switch columns {
    case .fixed(let numberOfColumns): numberOfColumns
    }
  }
  
  public var body: some View {
    let maxColumnWidth: CGFloat = (windowFrame.size.width - CGFloat(numberOfColumns - 1) * spacing) / CGFloat(numberOfColumns)
    VStack(alignment: alignment, spacing: spacing) {
      Group(subviews: content()) { subviews in
        let numberOfRows: Int = Int(ceil(Double(subviews.count) / Double(numberOfColumns)))
        ForEach(0..<numberOfRows, id: \.self) { row in
          HStack(spacing: spacing) {
            ForEach(subviews[row * numberOfColumns ..< min((row + 1) * numberOfColumns, subviews.count)]) { subview in
              subview
//                .frame(maxWidth: maxColumnWidth)
            }
            if row == numberOfRows - 1 && subviews.count % numberOfColumns > 0 {
              ForEach(0..<(numberOfColumns - subviews.count % numberOfColumns)) { _ in
                Color.clear
                  .frame(maxWidth: maxColumnWidth)
                  .frame(height: 1)
              }
            }
          }
        }
      }
    }
  }
}

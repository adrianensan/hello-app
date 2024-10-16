import SwiftUI

import HelloCore

public enum HelloVGridColumns: Sendable {
  case fixed(Int)
  case adaptive(minimum: CGFloat, maximum: CGFloat)
}

public struct HelloVGrid<Content: View>: View {
  
  #if os(iOS)
  @OptionalEnvironment(HelloSheetModel.self) private var sheetModel
  #endif
  
  private var columns: HelloVGridColumns
  private var alignment: HorizontalAlignment
  private var spacing: CGFloat
  @ViewBuilder private var content: @MainActor () -> Content
  
  @State private var itemHeight: CGFloat = 0
  @State private var numberOfRows: Int = 0
  
  public init(columns: HelloVGridColumns, alignment: HorizontalAlignment = .leading, spacing: CGFloat = 0, @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.columns = columns
    self.alignment = alignment
    self.spacing = spacing
    self.content = content
  }
  
  private var height: CGFloat {
    CGFloat(numberOfRows) * itemHeight + max(0, CGFloat(numberOfRows - 1)) * spacing
  }
  
  private func numberOfColumns(for width: CGFloat) -> Int {
    switch columns {
    case .fixed(let numberOfColumns): numberOfColumns
    case .adaptive(let minimum, _): Int(width / minimum)
    }
  }
  
  public var body: some View {
    GeometryReader { geometry in
      let numberOfColumns = numberOfColumns(for: geometry.size.width)
      let maxColumnWidth: CGFloat = (geometry.size.width - CGFloat(numberOfColumns - 1) * spacing) / CGFloat(numberOfColumns)
      VStack(alignment: alignment, spacing: spacing) {
        Group(subviews: content()) { subviews in
          let numberOfRows: Int = Int(ceil(Double(subviews.count) / Double(numberOfColumns)))
          let _ = Task {
            guard self.numberOfRows != numberOfRows else { return }
            self.numberOfRows = numberOfRows
          }
          ForEach(0..<numberOfRows, id: \.self) { row in
            HStack(spacing: spacing) {
              ForEach(subviews[row * numberOfColumns ..< min((row + 1) * numberOfColumns, subviews.count)]) { subview in
                subview
                  .frame(maxWidth: maxColumnWidth)
                //                .frame(maxWidth: maxColumnWidth)
              }
              if row == numberOfRows - 1 && subviews.count % numberOfColumns > 0 {
                ForEach(0..<(numberOfColumns - subviews.count % numberOfColumns)) { _ in
                  Color.clear
                    .frame(maxWidth: maxColumnWidth)
                    .frame(height: 1)
                }
              }
            }.readSize {
              guard itemHeight != $0.height else { return }
              itemHeight = $0.height
            }
          }
        }
      }.frame(width: geometry.size.width)
    }.frame(height: height)
      .onAppear {
        #if os(iOS)
        sheetModel?.waitingForSizing = true
        #endif
      }
  }
}

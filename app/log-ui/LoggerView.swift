import SwiftUI

import HelloCore

@MainActor
public struct LoggerView: View {
  
  class NonObservedStorage {
    var isFollowingNew: Bool = true
    var bottomY: CGFloat = 0
    var lastTopY: CGFloat = 0
    var lastBottomY: CGFloat = 0
  }
  
  @State var loggerObservable: LoggerObservable
  
  @State var nonObserved = NonObservedStorage()
  
  let overscrollInsets: EdgeInsets
  
  public init(logger: Logger = Log.logger, overscroll: EdgeInsets = EdgeInsets()) {
    _loggerObservable = State(initialValue: LoggerObservable(logger: logger))
    overscrollInsets = overscroll
  }
  
  public func scrollToBottom(scrollView: ScrollViewProxy, attempt: Int = 0) {
    guard attempt < 6 else { return }
    scrollView.scrollTo("logs-end")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
      if nonObserved.isFollowingNew && nonObserved.lastBottomY > nonObserved.bottomY {
        scrollToBottom(scrollView: scrollView, attempt: attempt + 1)
      }
    }
  }
  
  public var body: some View {
    ZStack {
      ScrollViewReader { scrollView in
        ScrollView(.vertical, showsIndicators: false) {
          VStack(spacing: 0) {
            Color.clear
              .frame(width: 1, height: 1)
              .background(GeometryReader { geometry -> Color in
                let minY = geometry.frame(in: .global).minY
                if minY > nonObserved.lastTopY && nonObserved.lastBottomY > nonObserved.bottomY {
                  nonObserved.isFollowingNew = false
                }
                nonObserved.lastTopY = minY
                return Color.clear
              })
            LazyVStack(alignment: .leading, spacing: 4) {
              ForEach(loggerObservable.logStatements) { logLine in
                LoggerLineView(logStatement: logLine)
              }
            }
            Color.clear
              .frame(width: 1, height: 1)
              .background(GeometryReader { geometry -> Color in
                let minY = geometry.frame(in: .global).minY
                if minY < nonObserved.bottomY {
                  nonObserved.isFollowingNew = true
                }
                nonObserved.lastBottomY = minY
                return Color.clear
              })
              .id("logs-end")
              .onChange(of: loggerObservable.lineCount) { _ in
                if nonObserved.isFollowingNew {
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                      scrollView.scrollTo("logs-end")
                    }
                  }
                }
              }.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                  scrollToBottom(scrollView: scrollView)
                }
              }
          }.padding(.leading, overscrollInsets.leading)
          .padding(.trailing, overscrollInsets.trailing)
        }.safeAreaInset(edge: .top) {
          Color.clear.frame(height: overscrollInsets.top)
        }.safeAreaInset(edge: .bottom) {
          Color.clear.frame(height: overscrollInsets.bottom)
        }
      }
      Color.clear
        .frame(width: 1, height: 1)
        .background(GeometryReader { geometry -> Color in
          nonObserved.bottomY = geometry.frame(in: .global).maxY
          return Color.clear
        })
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
  }
}

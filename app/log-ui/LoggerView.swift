//import SwiftUI
//
//import HelloCore
//
//@MainActor
//public struct LoggerView: View {
//  
//  class NonObservedStorage {
//    var isFollowingNew: Bool = true
//    var bottomY: CGFloat = 0
//    var lastTopY: CGFloat = 0
//    var lastBottomY: CGFloat = 0
//  }
//  
//  @State var loggerObservable: LoggerObservable
//  
//  @State var nonObserved = NonObservedStorage()
//  
//  let overscrollInsets: EdgeInsets
//  
//  public init(logger: Logger = Log.logger, overscroll: EdgeInsets = EdgeInsets()) {
//    _loggerObservable = State(initialValue: LoggerObservable(logger: logger))
//    overscrollInsets = overscroll
//  }
//  
//  public var body: some View {
//    ZStack {
//      ScrollViewReader { scrollView in
//        ScrollView(.vertical, showsIndicators: true) {
//          VStack(spacing: 0) {
//            Color.clear
//              .frame(width: 1, height: 1)
//              .background(GeometryReader { geometry -> Color in
//                let minY = geometry.frame(in: .global).minY
//                if minY > nonObserved.lastTopY && nonObserved.lastBottomY > nonObserved.bottomY {
//                  nonObserved.isFollowingNew = false
//                }
//                nonObserved.lastTopY = minY
//                return Color.clear
//              })
//            LazyVStack(alignment: .leading, spacing: 4) {
//              ForEach(loggerObservable.logStatements) { logLine in
//                LoggerLineView(logStatement: logLine)
//              }
//            }
//            Color.clear
//              .frame(width: 1, height: 1)
//              .background(GeometryReader { geometry -> Color in
//                let minY = geometry.frame(in: .global).minY
//                if minY < nonObserved.bottomY {
//                  nonObserved.isFollowingNew = true
//                }
//                nonObserved.lastBottomY = minY
//                return Color.clear
//              })
//              .id("logs-end")
//              .onChange(of: loggerObservable.lineCount) {
//                if nonObserved.isFollowingNew {
//                  Task {
//                    try await Task.sleep(seconds: 0.02)
//                    withAnimation(.easeInOut(duration: 0.1)) {
//                      scrollView.scrollTo("logs-end")
//                    }
//                  }
//                }
//              }.onAppear {
//                Task {
//                  try await Task.sleep(seconds: 0.02)
//                  scrollView.scrollTo("logs-end")
//                }
//              }
//          }.padding(.leading, overscrollInsets.leading)
//          .padding(.trailing, overscrollInsets.trailing)
//        }.safeAreaInset(edge: .top) {
//          Color.clear.frame(height: overscrollInsets.top)
//        }.safeAreaInset(edge: .bottom) {
//          Color.clear.frame(height: overscrollInsets.bottom)
//        }
//      }
//      Color.clear
//        .frame(width: 1, height: 1)
//        .background(GeometryReader { geometry -> Color in
//          nonObserved.bottomY = geometry.frame(in: .global).maxY
//          return Color.clear
//        })
//        .frame(maxHeight: .infinity, alignment: .bottom)
//    }
//  }
//}

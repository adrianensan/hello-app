#if os(iOS)
import SwiftUI

import HelloCore

@MainActor
public struct LogsNavigationPage: View {
  
  class NonObservedStorage {
    var isFollowingNew: Bool = true
    var bottomY: CGFloat = 0
    var lastTopY: CGFloat = 0
    var lastBottomY: CGFloat = 0
  }
  
  @Environment(\.theme) var theme
  @Environment(\.helloPagerConfig) var helloPagerConfig
  @Environment(HelloWindowModel.self) var windowModel
  
  @State var loggerObservable = LoggerObservable(logger: Log.logger)
  @State var scrollModel = HelloScrollModel()
  @State var nonObserved = NonObservedStorage()
  
  public init() {}
  
  public func scrollToBottom(attempt: Int = 0) {
    guard attempt < 6 else { return }
    scrollModel.scroll(to: .view(id: "logs-end"))
    
    Task {
      try await Task.sleep(seconds: 0.4)
      if nonObserved.isFollowingNew && nonObserved.lastBottomY > nonObserved.bottomY {
        scrollToBottom(attempt: attempt + 1)
      }
    }
  }
  
  public var body: some View {
    NavigationPage(title: "Logs",
                   model: scrollModel,
                   navBarContent: {
      ZStack {
        HelloButton(action: {
          windowModel.show(alert: .init(title: "Clear Logs",
                                          message: "Are you sure you want to clear all logs?",
                                          firstButton: .init(name: "Clear",
                                                             action: { Task { try await Log.logger.clear() } },
                                                             isDestructive: true),
                                          secondButton: .cancel()))
        }) {
          Image(systemName: "trash")
            .font(.system(size: 22, weight: .medium, design: .rounded))
            .foregroundStyle(theme.foreground.primary.style)
            .frame(width: 44, height: 44)
            .background(ClearClickableView())
        }.padding(.trailing, 16)
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
    }) {
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
          ForEach(loggerObservable.logStatements) {
            LoggerLineView(logStatement: $0)
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
              Task {
                try await Task.sleep(seconds: 0.02)
                scrollModel.scroll(to: .view(id: "logs-end"))
              }
            }
          }.onAppear {
            Task {
              try await Task.sleep(seconds: 0.02)
              scrollToBottom()
            }
          }
      }
    }.environment(\.helloPagerConfig, HelloPagerConfig(defaultNavBarHeight: helloPagerConfig.defaultNavBarHeight,
                                                       horizontalPagePadding: 8))
  }
}
#endif

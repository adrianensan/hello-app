#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct LogsNavigationPage: View {
  
  @Environment(\.theme) var theme
  @Environment(\.safeArea) var safeArea
  @Environment(\.helloPagerConfig) var helloPagerConfig
  @Environment(HelloWindowModel.self) var windowModel
  
  @State private var loggerModel = LoggerModel(logger: Log.logger)
  @State private var scrollModel = HelloScrollModel(showScrollIndicator: true)
  
  @NonObservedState private var isFollowingNew: Bool = true
  @NonObservedState private var bottomY: CGFloat = 0
  @NonObservedState private var lastTopY: CGFloat = 0
  @NonObservedState private var lastBottomY: CGFloat = 0
  
  public init() {}
  
  public var body: some View {
    ZStack {
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
              .font(.system(size: 20, weight: .regular))
              .foregroundStyle(theme.foreground.primary.style)
              .frame(width: 44, height: 44)
              .clickable()
          }.frame(maxWidth: .infinity, alignment: .trailing)
        }
      }) {
        VStack(spacing: 0) {
          Color.clear
            .frame(width: 1, height: 1)
            .readFrame {
              let minY = $0.minY
              if minY > lastTopY && lastBottomY > bottomY && isFollowingNew {
                isFollowingNew = false
              }
              lastTopY = minY
            }
          LazyVStack(alignment: .leading, spacing: 4) {
            ForEach(loggerModel.logStatements) { logStatement in
              LoggerLineView(logStatement: logStatement)
            }
          }.padding(.bottom, 68)
          Color.clear
            .frame(width: 1, height: 4)
            .readFrame {
              let minY = $0.minY
              if minY < bottomY && !isFollowingNew {
                isFollowingNew = true
              }
              lastBottomY = minY
            }
        }
      }.readFrame { bottomY = $0.maxY - safeArea.bottom + 20 }
      
      HelloButton(action: {
        windowModel.presentSheet { LogFilterSheet().environment(loggerModel) }
      }) {
        Image(systemName: "line.3.horizontal")
          .font(.system(size: 26, weight: .medium))
          .foregroundStyle(theme.accent.readableOverlayColor)
        //          .foregroundStyle(theme.floating.foreground.primary.style)
          .frame(width: 60, height: 60)
          .background(Circle().fill(theme.accent.style))
        //          .background(theme.floating.backgroundView(for: Circle()))
      }.shadow(color: .black.opacity(0.2), radius: 8)
        .padding(.trailing, 16)
        .padding(.bottom, safeArea.bottom + 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
    .transformEnvironment(\.helloPagerConfig) {
      $0.horizontalPagePadding = 8
    }.onChange(of: loggerModel.logStatements.count) { _ in
      if isFollowingNew {
        Task {
          try await Task.sleepForOneFrame()
          scrollModel.scroll(to: .bottom, animated: false)
        }
      }
    }.onAppear {
      loggerModel.setup()
      Task {
        try await Task.sleepForOneFrame()
        scrollModel.scroll(to: .bottom, animated: false)
      }
    }
  }
}
#endif

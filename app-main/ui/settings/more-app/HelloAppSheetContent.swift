#if os(iOS)
import SwiftUI
import StoreKit

import HelloCore
import HelloApp

public struct HelloAppSheetContent: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeAreaInsets
  @Environment(\.hasAppeared) private var hasAppeared
  
  @State private var isPresentingAppStoreOverlay: Bool = false
  
  var app: KnownApp
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      Spacer(minLength: 0)
      if !isPresentingAppStoreOverlay {
        HelloSection {
          HStack(spacing: 8) {
            KnownAppIconView(app: app, prefferedPlatform: .iOS)
              .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 8) {
              Text(app.name)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(theme.foreground.primary.style)
              Text(app.platforms.string)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(theme.foreground.tertiary.style)
            }
            Spacer(minLength: 0)
          }.padding(10)
            .background(theme.surface.backgroundColor)
        }.padding(.horizontal, 16)
          .padding(.bottom, safeAreaInsets.bottom + 22)
      }
    }.appStoreOverlay(isPresented: $isPresentingAppStoreOverlay) {
        SKOverlay.AppConfiguration(appIdentifier: app.appleID, position: .bottom)
      }.onChange(of: hasAppeared) {
        if hasAppeared {
//          Task {
//            try? await Task.sleepForOneFrame()
//            guard hasAppeared else { return }
            isPresentingAppStoreOverlay = true
//          }
        } else {
          isPresentingAppStoreOverlay = false
        }
      }
  }
}
#endif

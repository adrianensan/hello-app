#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct UIMetricsPage: View {
  
  @Environment(\.displayScale) private var displayScale
  @Environment(\.theme) private var theme
  @Environment(\.windowFrame) private var windowFrame
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PagerModel.self) private var pagerModel
  
  public init() {}
  
  public var body: some View {
    HelloPage(title: "UI Metrics") {
      VStack(spacing: 36) {
        HelloSection(title: "Screen") {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 4) {
              Text("Size (Points)")
                .font(.system(size: 16, weight: .regular))
              Spacer(minLength: 0)
              Text("\(windowModel.pointSize.width.string) x \(windowModel.pointSize.height.string)")
                .font(.system(size: 16, weight: .regular))
            }
          }
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 4) {
              Text("Size (Pixels)")
                .font(.system(size: 16, weight: .regular))
              Spacer(minLength: 0)
              Text("\(windowModel.effectiveScreenPixelSize.width) x \(windowModel.effectiveScreenPixelSize.height)")
                .font(.system(size: 16, weight: .regular))
            }
          }
          
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 4) {
              Text("Physical Size (Pixels)")
                .font(.system(size: 16, weight: .regular))
              Spacer(minLength: 0)
              Text("\(windowModel.physicalScreenPixelSize.width) x \(windowModel.physicalScreenPixelSize.height)")
                .font(.system(size: 16, weight: .regular))
            }
          }
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 4) {
              Text("Physical pixels per point")
                .font(.system(size: 16, weight: .regular))
              Spacer(minLength: 0)
              Text(windowModel.physicalPixelsPerPoint.string)
                .font(.system(size: 16, weight: .regular))
            }
          }
          
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 4) {
              Text("Pixels per point")
                .font(.system(size: 16, weight: .regular))
              Spacer(minLength: 0)
              Text(displayScale.string)
                .font(.system(size: 16, weight: .regular))
            }
          }
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 4) {
              Text("Physical Scale Factor")
                .font(.system(size: 16, weight: .regular))
              Spacer(minLength: 0)
              Text("\((windowModel.physicalPixelsPerPoint / displayScale).string)")
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
        HelloSection(title: "Window") {
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 4) {
              Text("Size (Points)")
                .font(.system(size: 16, weight: .regular))
              Spacer(minLength: 0)
              Text("\(windowFrame.width.string) x \(windowFrame.height.string)")
                .font(.system(size: 16, weight: .regular))
            }
          }
          HelloSectionItem(leadingPadding: false) {
            HStack(spacing: 4) {
              Text("Size (Pixels)")
                .font(.system(size: 16, weight: .regular))
              Spacer(minLength: 0)
              Text("\(Int(displayScale * windowFrame.width)) x \(Int(displayScale * windowFrame.height))")
                .font(.system(size: 16, weight: .regular))
            }
          }
        }
        Spacer(minLength: 0)
      }
    }
  }
}
#endif

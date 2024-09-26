#if os(iOS)
import SwiftUI
import StoreKit

import HelloCore
import HelloApp

//struct HelloSubscriptionOptionView: View {
//  
//  @Environment(HelloWindowModel.self) private var windowModel
//  @Environment(PagerModel.self) private var pagerModel
//  @Environment(\.theme) private var theme
//  
//  let subcription: HelloSubscriptionOption
//  let product: Product
//  @Binding var selectedOption: HelloSubscriptionOption
//  
//  public var body: some View {
//    HelloButton(clickStyle: .highlight, action: {
//      guard selectedOption != subcription else { return }
//      selectedOption = subcription
//    }) {
//      HStack(spacing: 0) {
//        RadioCheckmark(isSelected: subcription == selectedOption)
//          .padding(.horizontal, 16)
//        VStack(alignment: .leading, spacing: 4) {
//          Text(subcription.frequency.name)
//            .font(.system(size: 16, weight: .regular))
//          Text(product.displayPrice.deletingSuffix(".00"))
//            .font(.system(size: 16, weight: .bold))
//        }
//      }.foregroundStyle(theme.surfaceSection.foreground.primary.style)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .frame(height: 72)
//        .background(theme.surface.backgroundView(for: .rect(cornerRadius: 12)))
//        .overlay(RoundedRectangle(cornerRadius: 12)
//          .strokeBorder(theme.surface.accent.style.opacity(subcription == selectedOption ? 1 : 0), lineWidth: 2))
//    }
//  }
//}

struct HelloSubscriptionOptionView: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PagerModel.self) private var pagerModel
  @Environment(\.theme) private var theme
  
  let subcription: HelloSubscriptionOption
  let product: Product
  @Binding var selectedOption: HelloSubscriptionOption
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      guard selectedOption != subcription else { return }
      selectedOption = subcription
    }) {
      ZStack {
        Text(product.displayPrice.deletingSuffix(".00"))
          .font(.system(size: 16, weight: .medium))
          .foregroundStyle(theme.surfaceSection.foreground.primary.style)
//        Text("/" + subcription.frequency.unit)
//          .font(.system(size: 10, weight: .regular))
//          .foregroundStyle(theme.surfaceSection.foreground.tertiary.style)
//          .padding(4)
//          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
      }.frame(width: 64, height: 60)
        .background(theme.surfaceSection.backgroundView(for: .rect(cornerRadius: 12)))
        .overlay(RoundedRectangle(cornerRadius: 12)
          .strokeBorder(theme.surfaceSection.accent.style.opacity(subcription == selectedOption ? 1 : 0), lineWidth: 2))
    }
  }
}
#endif

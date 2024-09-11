#if os(iOS)
import SwiftUI
import StoreKit

import HelloCore
import HelloApp

struct HelloSubscriptionOptionsContent: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PagerModel.self) private var pagerModel
  @Environment(\.theme) private var theme
  
  let subcriptionModel: HelloSubscriptionModel = .main
  
  @Binding var selectedOption: HelloSubscriptionOption
  
  var showAllOptions: Bool = false
  
  private var selectedProduct: Product? {
    subcriptionModel.product(for: selectedOption)
  }
  
  public var body: some View {
    if let tier1MonthlyProduct = subcriptionModel.tier1MonthlyProduct,
       let tier1YearlyProduct = subcriptionModel.tier1YearlyProduct,
       let tier2MonthlyProduct = subcriptionModel.tier2MonthlyProduct,
       let tier2YearlyProduct = subcriptionModel.tier2YearlyProduct,
       let tier3MonthlyProduct = subcriptionModel.tier3MonthlyProduct,
       let tier3YearlyProduct = subcriptionModel.tier3YearlyProduct {
      VStack(spacing: 0) {
        HStack(spacing: 8) {
          HelloImageView(.resource(bundle: .helloApp, fileName: "red-heart.png"))
            .frame(width: 40, height: 40)
          //          .frame(height: 20)
          Text("Basic")
            .font(.system(size: 17, weight: .medium))
          
          Spacer(minLength: 0)
          
          HelloSubscriptionOptionView(subcription: .tier1Monthly, product: tier1MonthlyProduct, selectedOption: $selectedOption)
          HelloSubscriptionOptionView(subcription: .tier1Yearly, product: tier1YearlyProduct, selectedOption: $selectedOption)
        }.frame(height: 80)
          .padding(.leading, 12)
          .padding(.trailing, 10)
        
        theme.surface.divider.color.swiftuiColor
          .frame(height: theme.surface.divider.width)
        
        HStack(spacing: 8) {
          HelloImageView(.resource(bundle: .helloApp, fileName: "smiling-face-with-heart-eyes.png"))
            .frame(width: 40, height: 40)
          //          .frame(height: 20)
          VStack(alignment: .leading, spacing: 0) {
            Text("Supporter")
              .font(.system(size: 17, weight: .medium))
              .foregroundStyle(theme.foreground.primary.style)
            
            Text("Same as Basic, but costs twice as much! Your support means a lot! (+ Exclusive app icon)")
              .font(.system(size: 10, weight: .regular))
              .foregroundStyle(theme.foreground.tertiary.style)
              .fixedSize(horizontal: false, vertical: true)
          }
          
          Spacer(minLength: 0)
          
          HelloSubscriptionOptionView(subcription: .tier2Monthly, product: tier2MonthlyProduct, selectedOption: $selectedOption)
          HelloSubscriptionOptionView(subcription: .tier2Yearly, product: tier2YearlyProduct, selectedOption: $selectedOption)
        }.frame(height: 80)
          .padding(.leading, 12)
          .padding(.trailing, 10)
        
        theme.surface.divider.color.swiftuiColor
          .frame(height: theme.surface.divider.width)
        
        HStack(spacing: 8) {
          HelloImageView(.resource(bundle: .helloApp, fileName: "star-struck.png"))
            .frame(width: 40, height: 40)
          //          .frame(height: 20)
          
          VStack(alignment: .leading, spacing: 0) {
            Text("Superstar")
              .font(.system(size: 17, weight: .medium))
              .foregroundStyle(theme.foreground.primary.style)
            
            Text("Same as Basic, but much more expensive! Your support means the world! (+ Exclusive app icon)")
              .font(.system(size: 10, weight: .regular))
              .foregroundStyle(theme.foreground.tertiary.style)
              .fixedSize(horizontal: false, vertical: true)
          }
          
          Spacer(minLength: 0)
          
          HelloSubscriptionOptionView(subcription: .tier3Monthly, product: tier3MonthlyProduct, selectedOption: $selectedOption)
          HelloSubscriptionOptionView(subcription: .tier3Yearly, product: tier3YearlyProduct, selectedOption: $selectedOption)
        }.frame(height: 80)
          .padding(.leading, 12)
          .padding(.trailing, 10)
      }
        .background(theme.surface.backgroundColor)
    }
  }
}
#endif

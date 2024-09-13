#if os(iOS)
import SwiftUI
import StoreKit

import HelloCore
import HelloApp

struct HelloSubscriptionOpionsSectionContent: View {
  
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
      VStack(alignment: .leading, spacing: 16) {
        HStack(spacing: 16) {
          HelloSubscriptionOptionView(subcription: .tier1Monthly, product: tier1MonthlyProduct, selectedOption: $selectedOption)
          HelloSubscriptionOptionView(subcription: .tier1Yearly, product: tier1YearlyProduct, selectedOption: $selectedOption)
        }
        //            }.padding(16)
        //              .background(theme.surface.backgroundColor)
        
        if showAllOptions {
          //              HelloSection {
          //                VStack(alignment: .leading, spacing: 16) {
          HStack(spacing: 8) {
            HelloImageView(.resource(bundle: .helloApp, fileName: "red-heart.png"))
              .frame(width: 40, height: 40)
              .frame(height: 20)
            Text("Supporter Tier")
              .font(.system(size: 20, weight: .medium))
          }
          HStack(spacing: 16) {
            HelloSubscriptionOptionView(subcription: .tier2Monthly, product: tier2MonthlyProduct, selectedOption: $selectedOption)
            HelloSubscriptionOptionView(subcription: .tier2Yearly, product: tier2YearlyProduct, selectedOption: $selectedOption)
          }
          //                }.padding(16)
          //                  .background(theme.surface.backgroundColor)
          //              }.overlay(RoundedRectangle(cornerRadius: 12)
          //                .strokeBorder(theme.surfaceSection.accent.style.opacity(selectedOption.tier == 2 ? 1 : 0), lineWidth: 2))
          
          //              HelloSection {
          //                VStack(alignment: .leading, spacing: 16) {
          HStack(spacing: 8) {
            HelloImageView(.resource(bundle: .helloApp, fileName: "smiling-face-with-heart-eyes.png"))
              .frame(width: 40, height: 40)
              .frame(height: 20)
            Text("Superstar Tier")
              .font(.system(size: 20, weight: .medium))
          }
          HStack(spacing: 16) {
            HelloSubscriptionOptionView(subcription: .tier3Monthly, product: tier3MonthlyProduct, selectedOption: $selectedOption)
            HelloSubscriptionOptionView(subcription: .tier3Yearly, product: tier3YearlyProduct, selectedOption: $selectedOption)
          }
          
          //              }.overlay(RoundedRectangle(cornerRadius: 12)
          //                .strokeBorder(theme.surfaceSection.accent.style.opacity(selectedOption.tier == 3 ? 1 : 0), lineWidth: 2))
        }
      }//.padding(16)
//        .background(theme.surface.backgroundColor)
    }
  }
}

struct HelloSubscriptionPageContent: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PagerModel.self) private var pagerModel
  @Environment(\.theme) private var theme
  
  let subcriptionModel: HelloSubscriptionModel = .main
  
  @State private var selectedOption: HelloSubscriptionOption = .tier1Monthly
  @State private var showAllOptions: Bool = false
  @State private var isManageSubscriptionsPresented: Bool = false
  
  private var selectedProduct: Product? {
    subcriptionModel.product(for: selectedOption)
  }
  
  public var body: some View {
    VStack(spacing: 24) {
      if subcriptionModel.isActuallySubscribed {
        Text("Thank you for\nsubscribing!")
          .font(.system(size: 36, weight: .bold))
          .multilineTextAlignment(.center)
          .fixedSize()
          .foregroundStyle(theme.foreground.primary.style)
        
        Text("Your subscription is valid for ALL Hello apps")
          .font(.system(size: 17, weight: .medium))
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
          .foregroundStyle(theme.foreground.primary.style)
        
//        OtherHelloAppsView()
        Spacer(minLength: 0)
        if subcriptionModel.isSubscribedFromThisApp {
          HelloButton(action: { isManageSubscriptionsPresented = true }) {
            Text("Manage Subscription")
              .font(.system(size: 20, weight: .medium))
              .foregroundStyle(theme.surface.foreground.primary.style)
              .fixedSize()
              .padding(.horizontal, 16)
              .frame(height: 44)
              .background(theme.surface.backgroundView(for: .capsule))
          }
        } else if let knownApp = subcriptionModel.appSubscribedFrom {
          Text("Your subscription from \(knownApp.name) is valid here too!")
            .font(.system(size: 17, weight: .medium))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(theme.foreground.primary.style)
          
          Text("You can manage your subscription in either \(knownApp.name) or system settings")
            .font(.system(size: 17, weight: .medium))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(theme.foreground.primary.style)
          
          HelloButton(action: {  }) {
            Text("Open \(knownApp.name)")
              .font(.system(size: 20, weight: .medium))
              .foregroundStyle(theme.surface.foreground.primary.style)
              .fixedSize()
              .padding(.horizontal, 16)
              .frame(height: 44)
              .background(theme.surface.backgroundView(for: .capsule))
          }
        }
      } else {
        Text("Hello World")
          .font(.system(size: 36, weight: .bold))
          .multilineTextAlignment(.center)
          .fixedSize()
          .foregroundStyle(theme.foreground.primary.style)
        
        OtherHelloAppsView()
        
        if subcriptionModel.isPromo {
          Text("You have been granted access to premium features!")
            .font(.system(size: 17, weight: .medium))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(theme.foreground.primary.style)
        } else {
          Text("Unlock premium features for **ALL** Hello apps")
            .font(.system(size: 17, weight: .medium))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(theme.foreground.primary.style)
          
          Text("Themes • Custom App Icons • Sync")
            .font(.system(size: 17, weight: .medium))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(theme.foreground.primary.style)
        }
        
        Spacer(minLength: 0)
        
        if let tier1MonthlyProduct = subcriptionModel.tier1MonthlyProduct,
           let tier1YearlyProduct = subcriptionModel.tier1YearlyProduct,
           let tier2MonthlyProduct = subcriptionModel.tier2MonthlyProduct,
           let tier2YearlyProduct = subcriptionModel.tier2YearlyProduct,
           let tier3MonthlyProduct = subcriptionModel.tier3MonthlyProduct,
           let tier3YearlyProduct = subcriptionModel.tier3YearlyProduct {
          VStack(spacing: 4) {
            HStack(spacing: 8) {
              Spacer(minLength: 0)
              
              Text("Monthly")
                .font(.system(size: 16, weight: .medium))
                .frame(width: 64)
              
              Text("Yearly")
                .font(.system(size: 16, weight: .medium))
                .frame(width: 64)
            }.foregroundStyle(theme.foreground.secondary.style)
              .padding(.trailing, 10)
              .frame(maxWidth: 520)
            HelloSection {
              HelloSubscriptionOptionsContent(selectedOption: $selectedOption, showAllOptions: showAllOptions)
            }
          }
//            HelloSubscriptionOpionsSectionContent(selectedOption: $selectedOption, showAllOptions: showAllOptions)
            
            
            
            
            //            VStack(alignment: .leading, spacing: 16) {
            //              Text("Premium")
            //                .font(.system(size: 16, weight: .medium))
            //                .padding(.leading, 2)
            //              HStack(spacing: 16) {
            //                HelloSubscriptionOptionView(subcription: .tier1Monthly, product: tier1MonthlyProduct, selectedOption: $selectedOption)
            //                HelloSubscriptionOptionView(subcription: .tier1Yearly, product: tier1YearlyProduct, selectedOption: $selectedOption)
            //              }
            //              //            }.padding(16)
            //              //              .background(theme.surface.backgroundColor)
            //              
            //              if showAllOptions {
            //                //              HelloSection {
            //                //                VStack(alignment: .leading, spacing: 16) {
            //                Text("Supporter Tier")
            //                  .font(.system(size: 16, weight: .medium))
            //                  .padding(.leading, 2)
            //                HStack(spacing: 16) {
            //                  HelloSubscriptionOptionView(subcription: .tier2Monthly, product: tier2MonthlyProduct, selectedOption: $selectedOption)
            //                  HelloSubscriptionOptionView(subcription: .tier2Yearly, product: tier2YearlyProduct, selectedOption: $selectedOption)
            //                }
            //                //                }.padding(16)
            //                //                  .background(theme.surface.backgroundColor)
            //                //              }.overlay(RoundedRectangle(cornerRadius: 12)
            //                //                .strokeBorder(theme.surfaceSection.accent.style.opacity(selectedOption.tier == 2 ? 1 : 0), lineWidth: 2))
            //                
            //                //              HelloSection {
            //                //                VStack(alignment: .leading, spacing: 16) {
            //                Text("Superstar Tier")
            //                  .font(.system(size: 16, weight: .medium))
            //                  .padding(.leading, 2)
            //                HStack(spacing: 16) {
            //                  HelloSubscriptionOptionView(subcription: .tier3Monthly, product: tier3MonthlyProduct, selectedOption: $selectedOption)
            //                  HelloSubscriptionOptionView(subcription: .tier3Yearly, product: tier3YearlyProduct, selectedOption: $selectedOption)
            //                }
            //                
            //                //              }.overlay(RoundedRectangle(cornerRadius: 12)
            //                //                .strokeBorder(theme.surfaceSection.accent.style.opacity(selectedOption.tier == 3 ? 1 : 0), lineWidth: 2))
            //              }
            //            }.padding(16)
            //                  .background(theme.surface.backgroundColor)
//          }
          //          .overlay(RoundedRectangle(cornerRadius: 12)
          //            .strokeBorder(theme.surfaceSection.accent.style.opacity(showAllOptions && selectedOption.tier == 1 ? 1 : 0), lineWidth: 2))
          
//          if !showAllOptions {
//            HelloButton(action: {
//              withAnimation(.dampSpring) {
//                showAllOptions = true
//              }
//            }) {
//              (
//                Text(Image(systemName: "heart.fill"))
//                  .foregroundStyle(theme.accent.style)
//                +
//                Text(" I'd like to pay more ")
//                  .foregroundStyle(theme.foreground.primary.style)
//                +
//                Text(Image(systemName: "heart.fill"))
//                  .foregroundStyle(theme.accent.style)
//              ).font(.system(size: 20, weight: .medium))
//                .fixedSize()
//                .padding(.horizontal, 16)
//                .frame(height: 44)
//                .background(theme.surface.backgroundView(for: .capsule))
//            }
//          }
        } else {
          HelloSection {
            Text("Something went wrong")
          }
        }
        
        Spacer(minLength: 0)
        if let product = selectedProduct {
          HelloButton(action: {
            try await subcriptionModel.purchase(productID: product.id)
          }) {
            ZStack {
              if subcriptionModel.isPurchasing {
                LoadingSpinner(lineWidth: 4)
                  .frame(width: 36, height: 36)
                  .padding(.leading, 8)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
              VStack(spacing: 2) {
                Text("Subscribe")
                  .font(.system(size: 17, weight: .semibold))
                Text("\(product.displayPrice.deletingSuffix(".00"))/\(selectedOption.frequency.unit)")
                  .font(.system(size: 13, weight: .medium))
              }
            }.foregroundStyle(theme.theme.baseLayer.accent.mainColor.readableOverlayColor.swiftuiColor)
              .frame(height: 52)
              .frame(maxWidth: 220)
              .background(Capsule(style: .continuous).fill(theme.accent.style))
          }
        }
      }
    }.manageSubscriptionsSheet(isPresented: $isManageSubscriptionsPresented)
      .onDisappear { windowModel.stopConfetti() }
      .onChange(of: subcriptionModel.isActuallySubscribed, initial: true) {
        if subcriptionModel.isActuallySubscribed {
          windowModel.showConfetti()
        } else {
          windowModel.stopConfetti()
        }
      }
  }
}
#endif

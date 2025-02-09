#if os(iOS)
import SwiftUI
import MessageUI

import HelloCore
import HelloApp

struct EmailSetupSheet: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeArea
  @Environment(\.helloDismiss) private var dismiss
  @Environment(\.openURL) private var openURL
  
  @State private var isShowingMailSheet: Bool = false
  @State private var type: FeedbackType = .featureRequest
  @State private var includeLogs: Bool = false
  
  private var emailRecipient: String = "adrianensan@me.com"
  private var emailSubject: String { "[\(AppInfo.displayName)] [\(type.name)]" }
  private var emailBody: String { """
  
  ----------
  \(Device.current.description), \(OSInfo.description)
  App Version: \(AppInfo.version) (\(AppInfo.build))
  Tier: \(HelloSubscriptionModel.main.highestLevelSubscription?.type.description ?? "Free")
  Device ID: \(Persistence.mainActorValue(.deviceID))
  """
  }
  
  private var mailLink: URL? { URL(string: "mailto:\(emailRecipient)?subject=\(emailSubject)&body=\(emailBody)") }
  
  var body: some View {
    HelloPage(title: "Feedback", allowScroll: false) {
      VStack(spacing: 0) {
        HelloSection {
          FeedbackTypeItem(type: $type)
          FeedbackIncludeLogsRow(includeLogs: $includeLogs)
        }
        
        HStack(spacing: 16) {
          HelloButton(action: { dismiss() }) {
            Text("Cancel")
              .font(.system(size: 17, weight: .semibold))
              .foregroundStyle(theme.accent.style)
              .frame(height: 52)
              .frame(maxWidth: 220)
              .background(Capsule(style: .continuous).stroke(theme.accent.style, lineWidth: 1))
              .clickable()
          }
          HelloButton(action: {
            if MFMailComposeViewController.canSendMail() {
              isShowingMailSheet = true
            } else if let mailLink {
              openURL(mailLink)
              dismiss()
            }
          }) {
            Text("Continue")
              .font(.system(size: 17, weight: .semibold))
              .foregroundStyle(theme.accent.readableOverlayColor)
              .frame(height: 52)
              .frame(maxWidth: 220)
              .background(Capsule(style: .continuous).fill(theme.accent.style))
          }
        }.padding(.top, 24)
      }
    }.sheet(isPresented: $isShowingMailSheet) {
      MailView(
        to: emailRecipient,
        subject: emailSubject,
        body: emailBody,
        attachments: includeLogs ? [.logs(data: HelloEnvironment.object(for: .logger).generateRawString().data)] : [])
    }.onChange(of: isShowingMailSheet) {
      if !isShowingMailSheet {
        dismiss()
      }
    }
  }
}
#endif

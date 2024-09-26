#if os(iOS)
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import MessageUI

public struct MailView: UIViewControllerRepresentable {
  
  public struct Attachment: Sendable {
    var fileName: String
    var data: Data
    var type: String
    
    package static func logs(data: Data) -> Attachment {
      Attachment(fileName: "logs.txt", data: data, type: UTType.text.identifier)
    }
  }
  
  var recipient: String
  var subject: String
  var body: String
  var attachments: [Attachment]
  
  public init(to recipient: String, subject: String, body: String, attachments: [Attachment]) {
    self.recipient = recipient
    self.subject = subject
    self.body = body
    self.attachments = attachments
  }
  
  @Environment(\.presentationMode) var presentation
  
  public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    
    @Binding var presentation: PresentationMode
    
    init(presentation: Binding<PresentationMode>) {
      _presentation = presentation
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
      $presentation.wrappedValue.dismiss()
    }
  }
  
  public func makeCoordinator() -> Coordinator {
    return Coordinator(presentation: presentation)
  }
  
  public func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
    let vc = MFMailComposeViewController()
    vc.setToRecipients([recipient])
    vc.setSubject(subject)
    vc.setMessageBody(body, isHTML: false)
    for attachment in attachments {
      vc.addAttachmentData(attachment.data, mimeType: attachment.type, fileName: attachment.fileName)
    }
    
    vc.mailComposeDelegate = context.coordinator
    return vc
  }
  
  public func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                              context: UIViewControllerRepresentableContext<MailView>) {
    
  }
}
#endif

import UIKit
import MessageUI

extension UIViewController {
  func presentMail(with recipients: [String]? = nil, subject: String, body: String, isHTML: Bool = false, delegate: MFMailComposeViewControllerDelegate? = nil) {
    // Check if the user's device can send email
    guard MFMailComposeViewController.canSendMail() else {
      print("This device can't send email")
      return
    }
    
    // Create a new mail composer instance
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = delegate
    
    // Set the recipient, subject, and body of the email
    mailComposer.setToRecipients(recipients)
    mailComposer.setSubject(subject)
    mailComposer.setMessageBody(body, isHTML: isHTML)
    
    // Present the mail composer to the user
    present(mailComposer, animated: true)
  }
}

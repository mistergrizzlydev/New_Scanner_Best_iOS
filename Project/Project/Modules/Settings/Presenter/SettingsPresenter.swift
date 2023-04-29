import UIKit
import SafariServices
import MessageUI
import WhatsNewKit
import SwiftUI

protocol SettingsPresenterProtocol {
  func present()
  
  func showAppearance()
  func showStartAppWith()
  func grabDefaultEmail()
  
  func showScanCompression()
  func showPageSize()
  func showSortType()
  func showSmartCategories()
  
  func onDistortionTapped()
  func onCameraStabilizationTapped()
  
  func onPPTapped()
  func onTermsTapped()
  
  func showEmail(with type: AppConfiguration.Help)
  
  func onRateTapped()
  func onMoreAppsTapped()
  func onWhatsNewTapped()
}

final class SettingsPresenter: NSObject, SettingsPresenterProtocol {
  private weak var view: (SettingsViewControllerProtocol & UIViewController)!

  init(view: SettingsViewControllerProtocol & UIViewController) {
    self.view = view
    super.init()
    registerUpdatePDFNotifications()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func present() {
    view.prepare(with: .init(title: "Settings"))
  }
  
  func showAppearance() {
    let options = Appearance.allCases.compactMap { $0.name }
    let selectedOption = UserDefaults.appearance.rawValue
    let controller = SelectableBuilder().buildViewController(title: "Appearance", options: options, selectedOption: selectedOption)!
    view.navigationController?.pushViewController(controller, animated: true)
  }
  
  func showStartAppWith() {
    let options = StartType.allCases.compactMap { $0.rawValue }
    let selectedOption = UserDefaults.startType.rawValue
    let controller = SelectableBuilder().buildViewController(title: "Start App with", options: options, selectedOption: selectedOption)!
    view.navigationController?.pushViewController(controller, animated: true)
  }
  
  func grabDefaultEmail() {
    let text = UserDefaults.emailFromAccount.isEmpty ? nil : UserDefaults.emailFromAccount
    view.presentAlertWithTextField(message: "Link your email address for seamless sharing of documents and folders", keyboardType: .emailAddress,
                                   text: text, placeholder: "john.doe@example.com") { [weak self] result in
      UserDefaults.emailFromAccount = result
      self?.present()
    }
  }
  
  func showScanCompression() {
    let options = ImageSize.allCases.compactMap { $0.name }
    let selectedOption = UserDefaults.imageCompressionLevel.rawValue
    let controller = SelectableBuilder().buildViewController(title: "Scan Compression", options: options, selectedOption: selectedOption)!
    view.navigationController?.pushViewController(controller, animated: true)
  }
  
  func showPageSize() {
    let options = PageSize.allCases.compactMap { $0.name }
    let selectedOption = UserDefaults.pageSize.rawValue
    let controller = SelectableBuilder().buildViewController(title: "Default Page Size", options: options, selectedOption: selectedOption)!
    view.navigationController?.pushViewController(controller, animated: true)
  }
  
  func showSortType() {
    let options = SortType.allCases.compactMap { $0.rawValue }
    let selectedOption = UserDefaults.sortedFilesType.rawValue
    let controller = SelectableBuilder().buildViewController(title: "Default Sort type", options: options, selectedOption: selectedOption)!
    view.navigationController?.pushViewController(controller, animated: true)
  }
  
  func showSmartCategories() {
    let options = DocumentClasifierCategory.allCases.compactMap { $0.name }
    let selectedOption = UserDefaults.documentClasifierCategory.name
    let controller = SelectableBuilder().buildViewController(title: "Default Smart category", options: options, selectedOption: selectedOption)!
    view.navigationController?.pushViewController(controller, animated: true)
  }
  
  func onDistortionTapped() {
    UserDefaults.isDistorsionEnabled.toggle()
    present()
  }
  
  func onCameraStabilizationTapped() {
    UserDefaults.isCameraStabilizationEnabled.toggle()
    present()
  }
  
  func onPPTapped() {
    presentSafari(with: AppConfiguration.Help.privacyPolicy.rawValue)
  }
  
  func onTermsTapped() {
    presentSafari(with: AppConfiguration.Help.terms.rawValue)
  }
  
  func showEmail(with type: AppConfiguration.Help) {
    switch type {
    case .support:
      onEmailTapped(recipients: [AppConfiguration.Help.support.rawValue],
                    subject: "[TurboScan™] Support",
                    body: "\n\nVersion: \(Bundle.appVersion)\nDevice: \(Bundle.iOSVersion)\nSystem: \(Bundle.deviceModel)")
      
    case .featureRequeast:
      onEmailTapped(recipients: [AppConfiguration.Help.featureRequeast.rawValue],
                    subject: "[TurboScan™] Feature request", body: "")
      
    case .tellAFriend:
      view.share(["\(AppConfiguration.appStoreURL(with: AppConfiguration.AppStore.id.rawValue)) \n\(AppConfiguration.Help.tellAFriend.rawValue)"])
      
    default: break
    }
  }
  
  private func onEmailTapped(recipients: [String]?, subject: String, body: String) {
    view.presentMail(with: recipients, subject: subject, body: body, delegate: self)
  }
  
  func onRateTapped() {
    if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(AppConfiguration.AppStore.id.rawValue)?action=write-review") {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  func onWhatsNewTapped() {
    let whatsNew = WhatsNew(title: "What's New", features: [
      WhatsNew.Feature(image: WhatsNew.Feature.Image(systemName: "star.fill", foregroundColor: Color(UIColor.themeColor)),
                        title: "Add to Starred",
                        subtitle: "Quickly add and remove items to your favorites list."),

      WhatsNew.Feature(image: WhatsNew.Feature.Image(systemName: "doc.text.magnifyingglass", foregroundColor: Color(UIColor.themeColor)),
                        title: "Merge multiple PDFs",
                        subtitle: "Combine multiple PDFs into a single file with ease."),

      WhatsNew.Feature(image: WhatsNew.Feature.Image(systemName: "magnifyingglass.circle.fill", foregroundColor: Color(UIColor.themeColor)),
                        title: "Full-Text search",
                        subtitle: "Easily find any document by searching for specific text within your scans."),

      WhatsNew.Feature(image: WhatsNew.Feature.Image(systemName: "doc.text.viewfinder", foregroundColor: Color(UIColor.themeColor)),
                        title: "Text Vision",
                        subtitle: "Convert your scans into editable text for easy sharing and copying.")
    ], primaryAction: .init(title: "Continue", backgroundColor: Color(UIColor.themeColor), foregroundColor: Color(UIColor.bgColor)))
    
    let controller = WhatsNewViewController(whatsNew: whatsNew)
    view.present(controller, animated: true)
  }
  
  func onMoreAppsTapped() {
    if let url = URL(string: AppConfiguration.AppStore.moreApps.rawValue) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
}

extension SettingsPresenter {
  private func registerUpdatePDFNotifications() {
    // In another part of your code where you want to listen for the notification:
    let notificationCenter = NotificationCenter.default
    let queue = OperationQueue.main
    notificationCenter.addObserver(forName: .selectableScreenDidSelectOption, object: nil, queue: queue) { [weak self] notification in
      self?.present()
    }
  }
}

extension SettingsPresenter {
  private func presentSafari(with url: String) {
    let url = URL(string: url)!
    let config = SFSafariViewController.Configuration()
    config.entersReaderIfAvailable = true
    let safariViewController = SFSafariViewController(url: url, configuration: config)
    view.present(safariViewController, animated: true, completion: nil)
  }
}

extension SettingsPresenter: MFMailComposeViewControllerDelegate {
  // Handle the result of the email sending attempt
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    switch result {
    case .cancelled:
      debugPrint("Email cancelled")
    case .saved:
      debugPrint("Email saved")
    case .sent:
      debugPrint("Email sent")
    case .failed:
      debugPrint("Email send failed")
    default:
      break
    }
    
    // Dismiss the mail composer
    controller.dismiss(animated: true)
  }
}


//class ViewController: UIViewController, UITextFieldDelegate {
//
//    @IBOutlet weak var textField: UITextField!
//    
//    var selectedSuggestions: [String] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Set the delegate of the text field to this view controller
//        textField.delegate = self
//        
//        // Create the suggestions bar button items
//        let dateButton = UIBarButtonItem(title: "Date", style: .plain, target: self, action: #selector(didTapDateButton))
//        let timeButton = UIBarButtonItem(title: "Time", style: .plain, target: self, action: #selector(didTapTimeButton))
//        let secondsButton = UIBarButtonItem(title: "Seconds", style: .plain, target: self, action: #selector(didTapSecondsButton))
//        let receiptsButton = UIBarButtonItem(title: "Receipts", style: .plain, target: self, action: #selector(didTapReceiptsButton))
//        
//        // Set the suggestions on the input assistant item
//        textField.inputAssistantItem.leadingBarButtonGroups = [[dateButton, timeButton, secondsButton, receiptsButton]]
//    }
//    
//    @objc func didTapDateButton() {
//        selectedSuggestions.append("Date")
//        updateTextFieldText()
//    }
//    
//    @objc func didTapTimeButton() {
//        selectedSuggestions.append("Time")
//        updateTextFieldText()
//    }
//    
//    @objc func didTapSecondsButton() {
//        selectedSuggestions.append("Seconds")
//        updateTextFieldText()
//    }
//    
//    @objc func didTapReceiptsButton() {
//        selectedSuggestions.append("Receipts")
//        updateTextFieldText()
//    }
//    
//    func updateTextFieldText() {
//        let combinedString = selectedSuggestions.joined(separator: " ")
//        textField.text = getCurrentDateString() + " " + combinedString
//    }
//    
//    func getCurrentDateString() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd-MM-yyyy"
//        return formatter.string(from: Date())
//    }
//    
//    // MARK: - UITextFieldDelegate
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        // Clear the selected suggestions if the user manually types into the text field
//        selectedSuggestions.removeAll()
//        return true
//    }
//}

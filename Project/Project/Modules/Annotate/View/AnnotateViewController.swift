import UIKit
import QuickLook

protocol AnnotateViewControllerProtocol: AnyObject {
  func prepare(with viewModel: AnnotateViewModel)
}

final class AnnotateViewController: QLPreviewController, AnnotateViewControllerProtocol {
  private struct Constants {
    static let markupButtonAccessibilityIdentifier = "QLOverlayMarkupButtonAccessibilityIdentifier"
  }
  private var viewModel: AnnotateViewModel?
  
  override var editingInteractionConfiguration: UIEditingInteractionConfiguration {
    return .none
  }
  
  var presenter: AnnotatePresenterProtocol!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    pressMmarkupNavButton()
  }
  
  private func pressMmarkupNavButton() {
    delay(0.33) { [weak self] in
      guard let self = self else { return }
      
      if let navigation = self.children.first as? UINavigationController {
        if #available(iOS 16.0, *) {
          
          switch UIDevice.current.userInterfaceIdiom {
          case .pad:
            let navigationBar = navigation.view.subviews.first(where: { ($0 is UINavigationBar) }) as? UINavigationBar
            let navigationItem = navigationBar?.items?.first(where: { $0 is UINavigationItem })
            if let markupNavButton = navigationItem?.rightBarButtonItems?.first(where: { ($0 as UIBarButtonItem).accessibilityIdentifier == Constants.markupButtonAccessibilityIdentifier }) {
              _ = markupNavButton.target?.perform(markupNavButton.action, with: markupNavButton)
              self.onPlusbuttonPressed(markupNavButton)
            }
          default:
            let navigationBar = navigation.view.subviews.first(where: { ($0 is UINavigationBar) }) as? UINavigationBar
            let navigationItem = navigationBar?.items?.first(where: { $0 is UINavigationItem })
            if let markupNavButton = navigationItem?.rightBarButtonItems?.first(where: { ($0 as UIBarButtonItem).accessibilityIdentifier == Constants.markupButtonAccessibilityIdentifier  }) {
              _ = markupNavButton.target?.perform(markupNavButton.action, with: markupNavButton)
              self.onPlusbuttonPressed(markupNavButton)
            } else if let markupNavButton = navigationItem?.leftBarButtonItems?.first(where: { ($0 as UIBarButtonItem).accessibilityIdentifier == Constants.markupButtonAccessibilityIdentifier  }) {
              _ = markupNavButton.target?.perform(markupNavButton.action, with: markupNavButton)
              self.onPlusbuttonPressed(markupNavButton)
            } else {
              let viewController = navigation.viewControllers.first(where: { $0.toolbarItems != nil })
              if let markupNavButton = viewController?.toolbarItems?.first(where: { $0.accessibilityIdentifier == Constants.markupButtonAccessibilityIdentifier  }) {
                _ = markupNavButton.target?.perform(markupNavButton.action, with: markupNavButton)
                self.onPlusbuttonPressed(markupNavButton)
              }
            }
          }
        } else {
          if #available(iOS 14.0, *) {
            if let markupNavButton = (navigation.view.subviews.filter { $0 is UINavigationBar }.first as? UINavigationBar)?.items?.first?.rightBarButtonItems?.last {
              _ = markupNavButton.target?.perform(markupNavButton.action, with: markupNavButton)
              self.onPlusbuttonPressed(markupNavButton)
            }
          } else {
            if let markupUIButton = (navigation.view.subviews.filter { $0 is UINavigationBar }.first as? UINavigationBar)?.items?.first?.rightBarButtonItems?.last?.customView as? UIButton {
              markupUIButton.sendActions(for: .touchUpInside)
            }
          }
        }
        
        //          if !PurchaseManager.shared.isProVersionActive() {
        //              switch UIDevice.current.userInterfaceIdiom {
        //              case .pad:
        //                  if let shareButton = (navigation.view.subviews.filter { $0 is UINavigationBar }.first as? UINavigationBar)?.items?.first?.rightBarButtonItems?.first {
        //                      shareButton.isEnabled = false
        //                      shareButton.tintColor = .clear
        //                      shareButton.image = nil
        //                  }
        //              default:
        //                  if let shareButton = (navigation.view.subviews.filter { $0 is UIToolbar }.last as? UIToolbar)?.items?.first {
        //                      shareButton.isEnabled = false
        //                      shareButton.tintColor = .clear
        //                      shareButton.image = nil
        //                  }
        //              }
        //          }
      }
    }
  }
  
  private func onPlusbuttonPressed(_ sender: UIBarButtonItem) {
    //    delay(2) { [weak self] in
    //      guard let self = self else { return }
    //      if let navigation = self.children.first as? UINavigationController {
    //
    //      }
    //    }
  }
  
  private func setupViews() {
    // Setup views
  }
  
  func prepare(with viewModel: AnnotateViewModel) {
    self.viewModel = viewModel
    
    self.dataSource = self
    self.delegate = self
  }
}

extension AnnotateViewController: QLPreviewControllerDataSource {
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    1
  }
  
  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    return viewModel?.item ?? AnnotatePreviewItem(documentURL: viewModel?.item.previewItemURL)
  }
  
  func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
    return .updateContents
  }
}

extension AnnotateViewController: QLPreviewControllerDelegate {
  func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
    guard let previewItemURL = previewItem.previewItemURL else { return }
    NotificationCenter.default.post(name: .annotateScreenContentsDidUpdate, object: nil, userInfo: ["file_url": previewItemURL])
  }
  
  func previewController(_ controller: QLPreviewController, didSaveEditedCopyOf previewItem: QLPreviewItem, at modifiedContentsURL: URL) {
    guard let previewItemURL = previewItem.previewItemURL else { return }
    NotificationCenter.default.post(name: .annotateScreenEditedCopyDidSave, object: nil, userInfo: ["file_url": previewItemURL,
                                                                                                    "modified_file_url": modifiedContentsURL])
  }
  
  func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? { nil }
  
  func previewControllerWillDismiss(_ controller: QLPreviewController) {
    guard let viewModel = viewModel, let previewItemURL = viewModel.item.previewItemURL else { return }
    NotificationCenter.default.post(name: .annotateScreenWillDismiss, object: nil, userInfo: ["file_url": previewItemURL])
  }
  
  func previewControllerDidDismiss(_ controller: QLPreviewController) {
    guard let viewModel = viewModel, let previewItemURL = viewModel.item.previewItemURL else { return }
    NotificationCenter.default.post(name: .annotateScreenDidDismiss, object: nil, userInfo: ["file_url": previewItemURL])
  }
}

extension Notification.Name {
  static let annotateScreenWillDismiss = Notification.Name("AnnotateScreenWillDismiss")
  static let annotateScreenDidDismiss = Notification.Name("AnnotateScreenDidDismiss")
  
  static let annotateScreenContentsDidUpdate = Notification.Name("AnnotateScreenContentsDidUpdate")
  static let annotateScreenEditedCopyDidSave = Notification.Name("AnnotateScreenEditedCopyDidSave")
}













/*
 import UIKit
 import QuickLook
 
 class SignaturePreviewController: QLPreviewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
 private struct Constants {
 static let markupButtonAccessibilityIdentifier = "QLOverlayMarkupButtonAccessibilityIdentifier"
 }
 
 override var editingInteractionConfiguration: UIEditingInteractionConfiguration {
 return .none
 }
 
 var documentURL: URL?
 
 override func viewDidLoad() {
 super.viewDidLoad()
 self.dataSource = self
 self.delegate = self
 //    self.shouldOpenMarkup = true
 currentPreviewItemIndex = 1
 }
 
 override func viewDidAppear(_ animated: Bool) {
 super.viewDidAppear(animated)
 
 /*
  Summary
  
  Asks the Quick Look preview controller to recompute the display of the current preview item.
  */
 // refreshCurrentPreviewItem()
 //      if let itemViewController = self.currentPreviewItemViewController {
 //        itemViewController.additionalPreviewControllerOptions = [QLPreviewItemViewControllerOptionDisplayMode: QLPreviewItemViewControllerDisplayMode(rawValue: 2)!]
 //      }
 
 delay(0.33) { [weak self] in
 guard let self = self else { return }
 
 if let navigation = self.children.first as? UINavigationController {
 if #available(iOS 16.0, *) {
 
 switch UIDevice.current.userInterfaceIdiom {
 case .pad:
 let navigationBar = navigation.view.subviews.first(where: { ($0 is UINavigationBar) }) as? UINavigationBar
 let navigationItem = navigationBar?.items?.first(where: { $0 is UINavigationItem })
 if let markupNavButton = navigationItem?.rightBarButtonItems?.first(where: { ($0 as UIBarButtonItem).accessibilityIdentifier == Constants.markupButtonAccessibilityIdentifier }) {
 _ = markupNavButton.target?.perform(markupNavButton.action, with: markupNavButton)
 self.onPlusbuttonPressed(markupNavButton)
 }
 default:
 let navigationBar = navigation.view.subviews.first(where: { ($0 is UINavigationBar) }) as? UINavigationBar
 let navigationItem = navigationBar?.items?.first(where: { $0 is UINavigationItem })
 if let markupNavButton = navigationItem?.rightBarButtonItems?.first(where: { ($0 as UIBarButtonItem).accessibilityIdentifier == Constants.markupButtonAccessibilityIdentifier  }) {
 _ = markupNavButton.target?.perform(markupNavButton.action, with: markupNavButton)
 self.onPlusbuttonPressed(markupNavButton)
 } else if let markupNavButton = navigationItem?.leftBarButtonItems?.first(where: { ($0 as UIBarButtonItem).accessibilityIdentifier == Constants.markupButtonAccessibilityIdentifier  }) {
 _ = markupNavButton.target?.perform(markupNavButton.action, with: markupNavButton)
 self.onPlusbuttonPressed(markupNavButton)
 } else {
 let viewController = navigation.viewControllers.first(where: { $0.toolbarItems != nil })
 if let markupNavButton = viewController?.toolbarItems?.first(where: { $0.accessibilityIdentifier == Constants.markupButtonAccessibilityIdentifier  }) {
 _ = markupNavButton.target?.perform(markupNavButton.action, with: markupNavButton)
 self.onPlusbuttonPressed(markupNavButton)
 }
 }
 }
 } else {
 if #available(iOS 14.0, *) {
 if let markupNavButton = (navigation.view.subviews.filter { $0 is UINavigationBar }.first as? UINavigationBar)?.items?.first?.rightBarButtonItems?.last {
 _ = markupNavButton.target?.perform(markupNavButton.action, with: markupNavButton)
 self.onPlusbuttonPressed(markupNavButton)
 }
 } else {
 if let markupUIButton = (navigation.view.subviews.filter { $0 is UINavigationBar }.first as? UINavigationBar)?.items?.first?.rightBarButtonItems?.last?.customView as? UIButton {
 markupUIButton.sendActions(for: .touchUpInside)
 }
 }
 }
 
 //          if !PurchaseManager.shared.isProVersionActive() {
 //              switch UIDevice.current.userInterfaceIdiom {
 //              case .pad:
 //                  if let shareButton = (navigation.view.subviews.filter { $0 is UINavigationBar }.first as? UINavigationBar)?.items?.first?.rightBarButtonItems?.first {
 //                      shareButton.isEnabled = false
 //                      shareButton.tintColor = .clear
 //                      shareButton.image = nil
 //                  }
 //              default:
 //                  if let shareButton = (navigation.view.subviews.filter { $0 is UIToolbar }.last as? UIToolbar)?.items?.first {
 //                      shareButton.isEnabled = false
 //                      shareButton.tintColor = .clear
 //                      shareButton.image = nil
 //                  }
 //              }
 //          }
 }
 }
 }
 
 private func onPlusbuttonPressed(_ sender: UIBarButtonItem) {
 //    delay(2) { [weak self] in
 //      guard let self = self else { return }
 //      if let navigation = self.children.first as? UINavigationController {
 //
 //      }
 //    }
 }
 
 // MARK: - QLPreviewControllerDataSource
 
 func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
 return 1
 }
 
 func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
 let previewItem = PreviewItem(documentURL: documentURL)
 return previewItem
 }
 
 func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
 return .updateContents
 }
 
 func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
 
 }
 
 func previewController(_ controller: QLPreviewController, didSaveEditedCopyOf previewItem: QLPreviewItem, at modifiedContentsURL: URL) {
 
 }
 
 func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
 return nil
 }
 
 func previewControllerWillDismiss(_ controller: QLPreviewController) {
 
 }
 
 func previewControllerDidDismiss(_ controller: QLPreviewController) {
 
 }
 }
 */

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

protocol DocumentPreviewPresenterProtocol {
  func present()
  func onSignatureTapped()
  func onShareTapped()
  
  func onImportFileFromDocuments()
}

final class DocumentPreviewPresenter: NSObject, DocumentPreviewPresenterProtocol {
  private weak var view: (DocumentPreviewViewControllerProtocol & UIViewController)!
  let file: File
  let coordinator: Coordinator
  
  init(view: DocumentPreviewViewControllerProtocol & UIViewController,
       file: File, coordinator: Coordinator) {
    self.view = view
    self.file = file
    self.coordinator = coordinator
    super.init()
  }

  func present() {
    // Fetch data or smth else...
    view.prepare(with: .init(title: file.name, file: file))
  }
  
  func onSignatureTapped() {
    coordinator.navigateToAnnotation(controller: view, file: file)
  }
  
  func onShareTapped() {
    coordinator.presentShare(controller: view, items: [file.url])
  }
  
  func onImportFileFromDocuments() {
    coordinator.presentDocumentPickerViewController(controller: view, delegate: self)
  }
}

extension DocumentPreviewPresenter: UIDocumentPickerDelegate {
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    present()
  }
  
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    print("didPickDocumentsAt", urls)
  }
}

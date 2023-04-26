import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import QuickLook

protocol DocumentPreviewPresenterProtocol {
  func present()
  func onSignatureTapped()
  func onShareTapped()
  
  func onImportFileFromDocuments()
  func printDocument()
  func presentMove()
  func delete()
  func rearrange(with pdfDocument: PDFDoc?)
}

final class DocumentPreviewPresenter: NSObject, DocumentPreviewPresenterProtocol {
  private weak var view: (DocumentPreviewViewControllerProtocol & UIViewController)!
  private let file: File
  private let coordinator: Coordinator
  private let localFileManager: LocalFileManager
  
  init(view: DocumentPreviewViewControllerProtocol & UIViewController,
       file: File, coordinator: Coordinator,
       localFileManager: LocalFileManager) {
    self.view = view
    self.file = file
    self.coordinator = coordinator
    self.localFileManager = localFileManager
    super.init()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func present() {
    // Fetch data or smth else...
    view.prepare(with: .init(title: file.name, file: file))
    
    registerUpdatePDFNotifications()
  }
  
  func onSignatureTapped() {
    coordinator.navigateToAnnotation(controller: view, file: file, delegate: nil)
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

extension DocumentPreviewPresenter {
  func printDocument() {
    coordinator.presentPrint(with: file.url, jobName: file.name, showsNumberOfCopies: true, showsPaperOrientation: true)
  }
  
  func delete() {
    if localFileManager.delete(file) {
      view.navigationController?.popToRootViewController(animated: true)
    }
  }
  
  func rearrange(with pdfDocument: PDFDoc?) {
    guard let pdfDocument = pdfDocument else { return }
    let controller = RearrangeBuilder().buildViewController(with: pdfDocument)!
    let navigation = BaseNavigationController(rootViewController: controller)
    view.present(navigation, animated: true)
  }
}

extension DocumentPreviewPresenter {
  func presentMove() {
    let rootURL = localFileManager.getDocumentsURL()
    let filesToMove = localFileManager.contentsOfDirectory(url: rootURL, sortBy: UserDefaults.sortedFilesType)?.compactMap { $0.url }.filter { $0.hasDirectoryPath } ?? []
    
    guard !filesToMove.isEmpty else { return }
    
    let controller = ListBuilder().buildViewController(type: .detail(file.url), rootURL: rootURL, filesToMove: filesToMove)!
    let navigation = BaseNavigationController(rootViewController: controller)
    
    if let sheet = navigation.sheetPresentationController {
      sheet.detents = [.medium(), .large()]
      sheet.prefersGrabberVisible = true
      //        sheet.smallestUndimmedDetentIdentifier = .medium
      sheet.prefersScrollingExpandsWhenScrolledToEdge = false
      //        sheet.preferredCornerRadius = 30.0
    }
    
    view.present(navigation, animated: true)
  }
}

extension DocumentPreviewPresenter {
  private func registerUpdatePDFNotifications() {
    // In another part of your code where you want to listen for the notification:
    let notificationCenter = NotificationCenter.default
    let queue = OperationQueue.main
    
    notificationCenter.addObserver(forName: .newFileURL, object: nil, queue: queue) { [weak self] notification in
      // Handle the notification here
      
      if let userInfo = notification.userInfo, let url = userInfo["new_file_url"] as? URL {
        //        let newFile = File(url: url)
        //        self?.view.prepare(with: .init(title: newFile.name, file: newFile))
        self?.view.navigationController?.popToRootViewController(animated: true)
      }
    }
    
    // Make sure to remove the observer when it's no longer needed
    // notificationCenter.removeObserver(observer)
    
    notificationCenter.addObserver(forName: .annotateScreenContentsDidUpdate, object: nil, queue: queue) { [weak self] notification in
      if let userInfo = notification.userInfo, let previewItemURL = userInfo["file_url"] as? URL {
        let newFile = File(url: previewItemURL)
        self?.view.prepare(with: .init(title: newFile.name, file: newFile))
        self?.view.refreshPDFView()
        self?.deletePencilKitFiles()
      }
    }
    
    notificationCenter.addObserver(forName: .annotateScreenEditedCopyDidSave, object: nil, queue: queue) { [weak self] notification in
      // Handle the notification here
      
      if let userInfo = notification.userInfo, let previewItemURL = userInfo["file_url"] as? URL,
          let modifiedContentsURL = userInfo["modified_file_url"] as? URL {
        //        let newFile = File(url: url)
        debugPrint("previewItemURL ", previewItemURL)
        debugPrint("modifiedContentsURL ", modifiedContentsURL)
//        self?.deletePencilKitFiles()
      }
    }
    
    notificationCenter.addObserver(forName: .annotateScreenWillDismiss, object: nil, queue: queue) { [weak self] notification in
      // Handle the notification here
      
      if let userInfo = notification.userInfo, let url = userInfo["file_url"] as? URL {
        //        let newFile = File(url: url)
      }
    }
    
    notificationCenter.addObserver(forName: .annotateScreenDidDismiss, object: nil, queue: queue) { [weak self] notification in
      // Handle the notification here
      
      if let userInfo = notification.userInfo, let url = userInfo["file_url"] as? URL {
        //        let newFile = File(url: url)
      }
    }
    
    notificationCenter.addObserver(forName: .rearrangeScreenDeletePage, object: nil, queue: queue) { [weak self] notification in
      self?.present()
      self?.view.refreshPDFView()
    }
    
    notificationCenter.addObserver(forName: .rearrangeScreenDeleteLastPage, object: nil, queue: queue) { [weak self] notification in
      self?.view.navigationController?.popToRootViewController(animated: true)
    }
  }
}

extension DocumentPreviewPresenter {
  private func deletePencilKitFiles() {
    let url = file.url.deletingLastPathComponent()
    do {
      try localFileManager.deletePencilKitFiles(at: url)
    } catch {
      debugPrint(error.localizedDescription)
    }
  }
}

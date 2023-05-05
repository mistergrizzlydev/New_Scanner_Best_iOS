import UIKit
import PhotosUI
import MobileCoreServices
import UniformTypeIdentifiers
import QuickLook
import VisionKit
import Sandwich

protocol DocumentPreviewPresenterProtocol {
  func present()
  func onSignatureTapped()
  func onShareTapped(_ sender: UIBarButtonItem)
  
  func onImportFileFromGallery()
  func onImportFileFromDocuments()
  func onImportFileFromCamera()
  
  func onEditTapped(with image: UIImage?, pageIndex: Int)
  
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
  private var pageIndex: Int = 0
  
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
  
  func onShareTapped(_ sender: UIBarButtonItem) {
    coordinator.presentShare(controller: view, items: [file.url], barButtonItem: sender, sourceView: nil)
  }
  
  func onImportFileFromDocuments() {
    coordinator.presentDocumentPickerViewController(controller: view, delegate: self, allowsMultipleSelection: false)
  }
  
  func onImportFileFromGallery() {
    coordinator.presentImagePicker(in: view, delegate: self) { success in
      debugPrint(success)
    }
  }
  
  func onImportFileFromCamera() {
    coordinator.presentDocumentScanner(in: view, animated: true, delegate: self) { success in
      debugPrint(success)
    }
  }
  
  func onEditTapped(with image: UIImage?, pageIndex: Int) {
    self.pageIndex = pageIndex
    guard let image = image else { return }
    let scannerViewController = ImageScannerController(image: image, delegate: self)
    view.present(scannerViewController, animated: false)
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
    let filesToMove = localFileManager.contentsOfDirectory(url: rootURL, sortBy: UserDefaults.sortedFilesType)?.compactMap { $0.url }.filter { $0.isDirectory } ?? []
    
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
        self?.localFileManager.removeThumbnail(for: url)
        self?.view.navigationController?.popToRootViewController(animated: true)
      }
    }
    
    // Make sure to remove the observer when it's no longer needed
    // notificationCenter.removeObserver(observer)
    
    notificationCenter.addObserver(forName: .annotateScreenContentsDidUpdate, object: nil, queue: queue) { [weak self] notification in
      if let userInfo = notification.userInfo, let previewItemURL = userInfo["file_url"] as? URL {
        let newFile = File(url: previewItemURL)
        self?.view.prepare(with: .init(title: newFile.name, file: newFile))
        self?.localFileManager.removeThumbnail(for: previewItemURL)
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
        self?.localFileManager.removeThumbnail(for: previewItemURL)
        self?.localFileManager.removeThumbnail(for: modifiedContentsURL)
//        self?.deletePencilKitFiles()
      }
    }
    
    notificationCenter.addObserver(forName: .annotateScreenWillDismiss, object: nil, queue: queue) { [weak self] notification in
      // Handle the notification here
      
      if let userInfo = notification.userInfo, let url = userInfo["file_url"] as? URL {
        //        let newFile = File(url: url)
        self?.localFileManager.removeThumbnail(for: url)
      }
    }
    
    notificationCenter.addObserver(forName: .annotateScreenDidDismiss, object: nil, queue: queue) { [weak self] notification in
      // Handle the notification here
      
      if let userInfo = notification.userInfo, let url = userInfo["file_url"] as? URL {
        //        let newFile = File(url: url)
        self?.localFileManager.removeThumbnail(for: url)
      }
    }
    
    notificationCenter.addObserver(forName: .rearrangeScreenDeletePage, object: nil, queue: queue) { [weak self] notification in
      guard let self = self else { return }
      self.localFileManager.removeThumbnail(for: self.file.url)
      self.present()
      self.view.refreshPDFView()
    }
    
    notificationCenter.addObserver(forName: .rearrangeScreenDeleteLastPage, object: nil, queue: queue) { [weak self] notification in
      guard let self = self else { return }
      self.localFileManager.removeThumbnail(for: self.file.url)
      self.view.navigationController?.popToRootViewController(animated: true)
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

extension DocumentPreviewPresenter: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    debugPrint(results.count, results)
    
    picker.dismiss(animated: true) { [weak self] in
      guard let self = self else { return }
      results.loadImages { [weak self] (images, error) in
        guard let self = self, images?.isEmpty == false else { return }
        if let error = error {
          self.view.showDrop(message: "Error loading images: \(error.localizedDescription)", icon: .systemAlert())
        } else if let images = images {
          self.view.showLoadingView(title: "Inserting new pages")
          
          debugPrint(images.count, results.count)
          let tempPDFURL = URL.generateTempPDFURL()
          
          SandwichPDF.transform(key: AppConfiguration.OCR.personalKey, images: images,
                                toSandwichPDFatURL: tempPDFURL, isTextRecognition: UserDefaults.isOCREnabled,
                                quality: UserDefaults.imageCompressionLevel.compressionLevel()) { [weak self] error in
            self?.file.url.appendPDF(from: tempPDFURL)
            self?.present()
            self?.view.dismissLoadingView()
          }
        }
      }
    }
  }
}

extension DocumentPreviewPresenter: VNDocumentCameraViewControllerDelegate {
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    var images: [UIImage] = []
    
    for pageIndex in 0..<scan.pageCount {
      let image = scan.imageOfPage(at: pageIndex)
      images.append(image)
    }
    controller.dismiss(animated: true) { [weak self] in
      guard let self = self, !images.isEmpty else { return }
      self.view.showLoadingView(title: "Inserting new pages")
      
      let tempPDFURL = URL.generateTempPDFURL()
      
      SandwichPDF.transform(key: AppConfiguration.OCR.personalKey, images: images,
                            toSandwichPDFatURL: tempPDFURL, isTextRecognition: UserDefaults.isOCREnabled,
                            quality: UserDefaults.imageCompressionLevel.compressionLevel()) { [weak self] error in
        self?.file.url.appendPDF(from: tempPDFURL)
        self?.present()
        self?.view.dismissLoadingView()
      }
    }
  }
  
  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    controller.dismiss(animated: true, completion: nil)
  }
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
    controller.dismiss(animated: true)
  }
}

extension DocumentPreviewPresenter: UIDocumentPickerDelegate {
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    present()
  }
  
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    debugPrint("didPickDocumentsAt", urls)
    guard let url = urls.first else { return }
    
    file.url.appendPDF(from: url)
    present()
  }
}

extension DocumentPreviewPresenter: ImageScannerControllerDelegate {
  func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
    view.presentAlert(message: error.localizedDescription, alerts: [UIAlertAction(title: "Ok", style: .default)])
  }
  
  func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
    scanner.dismiss(animated: false)
    let image = results.enhancedImage ?? results.croppedScan.image
    
    view.showLoadingView(title: "Updating PDF file")
    let tempPDFURL = URL.generateTempPDFURL()
    
    SandwichPDF.transform(key: AppConfiguration.OCR.personalKey, images: [image],
                          toSandwichPDFatURL: tempPDFURL, isTextRecognition: UserDefaults.isOCREnabled,
                          quality: UserDefaults.imageCompressionLevel.compressionLevel()) { [weak self] error in
      self?.file.url.appendPDF(from: tempPDFURL, andRefreshAtPage: self?.pageIndex ?? 0 )
      self?.present()
      self?.view.dismissLoadingView()
    }
  }
  
  func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
    scanner.dismiss(animated: false)
  }
}

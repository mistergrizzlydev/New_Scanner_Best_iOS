import UIKit
import PhotosUI
import VisionKit
import Sandwich

protocol DocumentsPresenterProtocol {
  func present()
  func on(sortBy sortType: SortType)
  func didSelect(at index: IndexPath, viewModel: DocumentsViewModel)
  
  var sortedFilesType: SortType { get }
  
  func createNewFolder()
  
  func presentCamera(animated: Bool)
  func presentPhotoLibrary()
  
  func onDetailsTapped(_ viewModel: DocumentsViewModel)
  func onShareTapped(_ viewModels: [DocumentsViewModel], item: UIBarButtonItem?, sourceView: UIView?)
  func onStarredTapped(_ viewModel: DocumentsViewModel)
  func onCopyTapped(_ viewModel: DocumentsViewModel)
  
  func onRenameTapped(_ viewModel: DocumentsViewModel)
  func onDeleteTapped(_ viewModels: [DocumentsViewModel])
  
  func duplicate(for viewModels: [DocumentsViewModel]?)
  
  func presentMove(selectedViewModels: [DocumentsViewModel], viewModels: [DocumentsViewModel])
  
  func checkMergeButton(for viewModels: [DocumentsViewModel]?)
  func merge(viewModels: [DocumentsViewModel]?)
  
  func didSearch(for text: String, in scope: SearchScope) -> [DocumentsViewModel]
}

final class DocumentsPresenter: NSObject, DocumentsPresenterProtocol {
  private struct Constants {
    
  }
  
  private weak var view: (DocumentsViewControllerProtocol & UIViewController)!
  
  let coordinator: Coordinator
  let localFileManager: LocalFileManager
  let folder: Folder
  let type: DocumentsType
  
  init(view: DocumentsViewControllerProtocol & UIViewController,
       coordinator: Coordinator,
       localFileManager: LocalFileManager,
       folder: Folder,
       type: DocumentsType) {
    self.view = view
    self.coordinator = coordinator
    self.localFileManager = localFileManager
    self.folder = folder
    self.type = type
    super.init()
    
    registerNotifications()
  }
  
  func present() {
    switch type {
    case .myScans:
      if let viewModels = localFileManager.contentsOfDirectory(url: folder.url, sortBy: UserDefaults.sortedFilesType)?.compactMap({ DocumentsViewModel(file: $0) }) {
        if localFileManager.isRootDirectory(url: folder.url) {
          view.prepare(with: viewModels, title: type.title)
        } else {
          view.prepare(with: viewModels, title: folder.name)
        }
      }
      
      if UserDefaults.startType == .camera, VNDocumentCameraViewController.isSupported, !UserDefaults.wasStartTypeLaunched  {
        presentCamera(animated: false)
      }
      
//      For testing
//      if UserDefaults.startType == .camera, !UserDefaults.wasStartTypeLaunched {
//        presentPhotoLibrary()
//        UserDefaults.wasStartTypeLaunched = true
//      }
    case .starred:
      let documents = localFileManager.contentsOfDirectory(url: folder.url, sortBy: UserDefaults.sortedFilesType)?.filter { $0.isFileStarred() }
      if let viewModels = documents?.compactMap({ DocumentsViewModel(file: $0) }) {
        if localFileManager.isRootDirectory(url: folder.url) {
          view.prepare(with: viewModels, title: type.title)
        } else {
          view.prepare(with: viewModels, title: folder.name)
        }
      }
    }
    
    view.updateEditButtonItemEnabled()
  }
  
  private func registerNotifications() {
    let notificationCenter = NotificationCenter.default
    let queue = OperationQueue.main
    notificationCenter.addObserver(forName: .moveFolderOrFile, object: nil, queue: queue) { [weak self] notification in
      self?.present()
      self?.view.endEditing()
    }
  }
  
  func on(sortBy sortType: SortType) {
    UserDefaults.sortedFilesType = sortType
    present()
  }
  
  var sortedFilesType: SortType {
    UserDefaults.sortedFilesType
  }
  
  func didSelect(at index: IndexPath, viewModel: DocumentsViewModel) {
    switch viewModel.file.type {
    case .folder:
      coordinator.navigateToDocuments(from: view, type: type, folder: viewModel.file as! Folder)
    case .file:
      coordinator.navigateToDocumentPreview(from: view.navigationController, file: viewModel.file as! File)
    }
  }
  
  func didSearch(for text: String, in scope: SearchScope) -> [DocumentsViewModel] {
    let documents = localFileManager.searchInDirectory(url: folder.url, searchFor: text)

    switch scope {
    case .all:
      return documents.compactMap({ DocumentsViewModel(file: $0) })
    case .folders:
      return documents.compactMap({ DocumentsViewModel(file: $0) }).filter { $0.file.type == .folder }
    case .files:
      return documents.compactMap({ DocumentsViewModel(file: $0) }).filter { $0.file.type == .file }
    }
  }
  
  func onShareTapped(_ viewModels: [DocumentsViewModel], item: UIBarButtonItem?, sourceView: UIView?) {
    let urls = viewModels.map { $0.file.url }
    coordinator.presentShare(controller: view, items: urls, barButtonItem: item, sourceView: sourceView)
  }
  
  func onDetailsTapped(_ viewModel: DocumentsViewModel) {
    guard let details = viewModel.file.details() else { return }
    
    let title = "File Information"
    let okAction = UIAlertAction(title: "OK", style: .default) { action in }
    view.presentAlert(withTitle: title, message: details, alerts: [okAction])
  }
  
  func onStarredTapped(_ viewModel: DocumentsViewModel) {
    if viewModel.file.isFileStarred() {
      viewModel.file.unstarFile()
    } else {
      viewModel.file.starFile()
    }
    
    present()
    
    let message = viewModel.file.isFileStarred() ? "File removed from Starred" : "File added to Starred"
    let icon = UIImage(systemName: FileManagerAction.star.iconName(file: viewModel.file))
    view.showDrop(message: message, icon: icon)
  }
  
  func onCopyTapped(_ viewModel: DocumentsViewModel) {
    if let pdfData = NSData(contentsOfFile: viewModel.file.url.path) {
      //    UIPasteboard.copyContentsOfFolderToClipboard(at: viewModel.file.url)
      let pasteboard = UIPasteboard.general
      pasteboard.items = []
      pasteboard.setData(pdfData as Data, forPasteboardType: "com.adobe.pdf")
      
      /*
       if let pngData = self.pngData(size, dpi: dpi, design: design, logoTemplate: logoTemplate) {
       pasteboard.setData(pngData, forPasteboardType: String("public.png"))
       }
       */
      
      let message = "File copied to clipboard"
      let icon = UIImage(systemName: FileManagerAction.copy.iconName(file: viewModel.file))
      view.showDrop(message: message, icon: icon)
    }
  }
  
  func onRenameTapped(_ viewModel: DocumentsViewModel) {
    // Handle rename action
    debugPrint("Rename action tapped")
    present()
    view.presentAlertWithTextField(title: "Rename File",
                                   message: "Enter a new name for the file:",
                                   placeholder: viewModel.file.name) { text in
      // TODO: - finish it
    }
  }
  
  func onDeleteTapped(_ viewModels: [DocumentsViewModel]) {
    let urls = viewModels.compactMap { $0.file.url }
    
    do {
      try localFileManager.delete(urls)
      
      if viewModels.count > 1 {
        let message = "Files deleted successfully"
        let icon = UIImage(systemName: FileManagerAction.delete.defaultIconName)
        view.showDrop(message: message, icon: icon)
      } else {
        guard let viewModel = viewModels.first else { return }
        let message = viewModel.file.type == .folder ? "Folder deleted successfully" : "File deleted successfully"
        let icon = UIImage(systemName: FileManagerAction.delete.defaultIconName)
        view.showDrop(message: message, icon: icon)
      }
      
    } catch {
      view.showDrop(message: error.localizedDescription, icon: .systemAlert())
    }
    
    present()
    view.endEditing()
  }
  
  func presentMove(selectedViewModels: [DocumentsViewModel], viewModels: [DocumentsViewModel]) {
    let rootURL = localFileManager.getDocumentsURL()
    let filesToMove = selectedViewModels.compactMap { $0.file.url }
    guard !filesToMove.isEmpty else { return }
    let controller = ListBuilder().buildViewController(rootURL: rootURL, filesToMove: filesToMove)!
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

extension DocumentsPresenter {
  func createNewFolder() {
    view.presentAlertWithTextField(title: "Create Folder",
                                   message: "Please enter a name for the new folder:",
                                   placeholder: "Folder Name") { [weak self] folderName in
      guard let self = self else { return }
      // Handle the folder name entered by the user
      let name = folderName.isEmpty ? "New Folder" : folderName
      
      do {
        let newFolderURL = try self.localFileManager.createFolder(with: name, at: self.folder.url)
        debugPrint(newFolderURL)
      } catch {
        debugPrint(error.localizedDescription)
        self.view.showDrop(message: error.localizedDescription, icon: .systemAlert())
      }
      
      self.present()
    }
  }
}

extension DocumentsPresenter {
  func duplicate(for viewModels: [DocumentsViewModel]?) {
    guard let viewModels = viewModels, !viewModels.isEmpty else {
      view.display(toolbarButtonAction: .duplicate, isEnabled: false)
      return
    }
    let urls = viewModels.compactMap { $0.file.url }
    do {
      try localFileManager.duplicateFiles(urls)
      present()
      view.endEditing()
    } catch {
      self.view.showDrop(message: error.localizedDescription, icon: .systemAlert())
    }
  }
}

extension DocumentsPresenter {
  func checkMergeButton(for viewModels: [DocumentsViewModel]?) {
    guard let viewModels = viewModels, !viewModels.isEmpty else {
      // No files/folders to merge, so disable the merge button
      view.display(toolbarButtonAction: .merge, isEnabled: false)
      view.display(toolbarButtonAction: .duplicate, isEnabled: false)
      return
    }
    
    if viewModels.count == 1 {
      // Only one file/folder, so disable the merge button
      view.display(toolbarButtonAction: .merge, isEnabled: false)
      
      if viewModels.first?.file.type == .file {
        view.display(toolbarButtonAction: .duplicate, isEnabled: true)
      } else {
        view.display(toolbarButtonAction: .duplicate, isEnabled: false)
      }
      
    } else {
      let containsFolders = viewModels.contains { $0.file.type == .folder }
      let containsFiles = viewModels.contains { $0.file.type == .file }
      
      //      if containsFolders && containsFiles {
      //        // Mixed files and folders, so disable the merge button
      //        view.display(toolbarButtonAction: .merge, isEnabled: false)
      //      } else {
      //        // Only files or only folders, so enable the merge button
      //        view.display(toolbarButtonAction: .merge, isEnabled: true)
      //      }
      
      if containsFiles && !containsFolders {
        view.display(toolbarButtonAction: .duplicate, isEnabled: true)
        view.display(toolbarButtonAction: .merge, isEnabled: true)
      } else {
        view.display(toolbarButtonAction: .duplicate, isEnabled: false)
        view.display(toolbarButtonAction: .merge, isEnabled: false)
      }
    }
  }
  
  func merge(viewModels: [DocumentsViewModel]?) {
    guard let viewModels = viewModels, !viewModels.isEmpty else {
      // No files/folders to merge, so disable the merge button
      view.display(toolbarButtonAction: .merge, isEnabled: false)
      return
    }
    
    if viewModels.count == 1 {
      // Only one file/folder, so disable the merge button
      view.display(toolbarButtonAction: .merge, isEnabled: false)
    } else {
      let folders = viewModels.filter { $0.file.type == .folder }//.contains { $0.file.type == .folder }
      let files = viewModels.filter { $0.file.type == .file }//contains { $0.file.type == .file }
      let containsFolders = !folders.isEmpty
      let containsFiles = !files.isEmpty
      
      if containsFolders && containsFiles {
        // Mixed files and folders, so disable the merge button
        view.display(toolbarButtonAction: .merge, isEnabled: false)
      } else {
        // Only files or only folders, so enable the merge button
        view.display(toolbarButtonAction: .merge, isEnabled: true)
      }
      
      if folders.isEmpty && !files.isEmpty {
        view.presentAlertWithTextField(title: "Merge PDFs",
                                       message: "Enter a name for the merged PDF:",
                                       placeholder: "Merged PDF Name") { [weak self] name in
          guard let self = self else { return }
          // Handle the folder name entered by the user
          let name = name.isEmpty ? "New PDF (merged)" : name
          let urls = files.compactMap { $0.file.url }
          self.localFileManager.mergePDF(urls: urls, with: name, toRootURL: self.folder.url)
          self.present()
          self.view.endEditing()
        }
      } else {
        view.presentAlertWithTextField(title: "Merge Folders",
                                       message: "Enter a name for the merged folder:",
                                       placeholder: "Merged Folder Name") { [weak self] name in
          guard let self = self else { return }
          // Handle the folder name entered by the user
          let name = name.isEmpty ? "New Folder (merged)" : name
          let urls = folders.compactMap { $0.file.url }
          self.localFileManager.mergeFolders(urls: urls, with: name, toRootURL: self.folder.url)
          self.present()
          self.view.endEditing()
        }
      }
    }
  }
}

extension DocumentsPresenter {
  func presentCamera(animated: Bool = true) {
    coordinator.presentDocumentScanner(in: view, animated: animated, delegate: self) { success in
      debugPrint(success)
    }
  }
  
  func presentPhotoLibrary() {
    coordinator.presentImagePicker(in: view, delegate: self) { success in
      debugPrint(success)
      
      if success {
        
      } else {
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settings = UIAlertAction(title: "Settings", style: .default, handler: { _ in
          if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
          }
        })
        
        self.view.presentAlert(withTitle: "Photo Library Access Denied", message: "Please allow access to your photo library in Settings to import photos.", alerts: [cancel, settings])
      }
    }
  }
}

extension DocumentsPresenter: VNDocumentCameraViewControllerDelegate {
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    // Handle the scanned document
    var images: [UIImage] = []
    
    for pageIndex in 0..<scan.pageCount {
      let image = scan.imageOfPage(at: pageIndex)
      images.append(image)
    }
    controller.dismiss(animated: true, completion: nil)
    
    view.showLoadingView(title: "Creating new document from images")
    let url = folder.url.appendingPathComponent(folder.url.generateFileName)
    
    // add here doc clasifier for naming...
    SandwichPDF.transform(key: AppConfiguration.OCR.personalKey, images: images,
                          toSandwichPDFatURL: url, isTextRecognition: UserDefaults.isOCREnabled,
                          quality: UserDefaults.imageCompressionLevel.compressionLevel()) { [weak self] error in
      self?.present()
      self?.view.dismissLoadingView()
//      controller.dismiss(animated: true, completion: nil) // trying
    }
  }
  
  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    controller.dismiss(animated: true, completion: nil)
  }
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
    controller.dismiss(animated: true)
  }
}

extension DocumentsPresenter: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    debugPrint(results.count, results)
    picker.dismiss(animated: true)
    
    view.showLoadingView(title: "Creating new document from images")
    
    results.loadImages { [weak self] (images, error) in
      guard let self = self else { return }
      if let error = error {
        self.view.showDrop(message: "Error loading images: \(error.localizedDescription)", icon: .systemAlert())
      } else if let images = images {
        debugPrint(images.count, results.count)
        let url = self.folder.url.appendingPathComponent(self.folder.url.generateFileName)
        SandwichPDF.transform(key: AppConfiguration.OCR.personalKey, images: images,
                              toSandwichPDFatURL: url, isTextRecognition: UserDefaults.isOCREnabled,
                              quality: UserDefaults.imageCompressionLevel.compressionLevel()) { [weak self] error in
          self?.present()
          self?.view.dismissLoadingView()
        }
      }
    }
  }
}

extension ImageSize {
  func compressionLevel() -> CompressionLevel {
    switch self {
    case .low, .small:
      return .low
    case .medium:
      return .medium
    case .original:
      return .original
    }
  }
}

extension URL {
  var generateFileName: String {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "MMM dd yyyy, hh:mm:s a"
//    let dateString = formatter.string(from: Date())
////
//    let name = Locale.current.name(self)
//    let fileName = "\(name).pdf"
    return Locale.current.name(self)
  }
}

extension Locale {
  func name(_ rootURL: URL) -> String {
    let name = Tag.convertToDate(from: UserDefaults.standard.selectedTags)
    let fileName = "\(name).pdf"
    let fileURL = rootURL.appendingPathComponent(fileName)
    
    return FileManager.default.validateFolderName(at: fileURL) ?? fileName
  }
}

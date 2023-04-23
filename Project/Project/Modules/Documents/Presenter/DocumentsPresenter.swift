import UIKit

enum DocumentsType {
  case myScans
  case starred
  
  var title: String {
    switch self {
    case .myScans: return "My Scans"
    case .starred: return "Starred Documents"
    }
  }
  
  var tabBarItemName: String {
    switch self {
    case .myScans: return "My Scans"
    case .starred: return "Starred"
    }
  }
  
  var image: UIImage {
    switch self {
    case .myScans: return .systemFolder()
    case .starred: return .systemStar()
    }
  }
}

protocol DocumentsPresenterProtocol {
  func present()
  func on(sortBy sortType: SortType)
  func didSelect(at index: IndexPath, viewModel: DocumentsViewModel)
  
  var sortedFilesType: SortType { get }
  
  func createNewFolder()
  
  func onDetailsTapped(_ viewModel: DocumentsViewModel)
  func onShareTapped(_ viewModels: [DocumentsViewModel])
  func onStarredTapped(_ viewModel: DocumentsViewModel)
  func onCopyTapped(_ viewModel: DocumentsViewModel)
  func onRenameTapped(_ viewModel: DocumentsViewModel)
  func onDeleteTapped(_ viewModels: [DocumentsViewModel])
  
  func duplicate(for viewModels: [DocumentsViewModel]?)
  
  func presentMove(selectedViewModels: [DocumentsViewModel], viewModels: [DocumentsViewModel])
  
  func checkMergeButton(for viewModels: [DocumentsViewModel]?)
  func merge(viewModels: [DocumentsViewModel]?)
}

final class DocumentsPresenter: DocumentsPresenterProtocol {
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
  
  func onShareTapped(_ viewModels: [DocumentsViewModel]) {
    let urls = viewModels.map { $0.file.url }
    coordinator.presentShare(controller: view, items: urls)
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
    print("Rename action tapped")
    
    present()
    
    view.presentAlertWithTextField(title: "Rename File",
                                   message: "Enter a new name for the file:",
                                   placeholder: viewModel.file.name) { text in
      
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
//    guard let viewModels = viewModels, !viewModels.isEmpty else { return }
//    let urls = viewModels.compactMap { $0.file.url }
//
//    for url in urls {
//      do {
//        try FileManager.default.duplicateFile(at: url)
//      } catch {
//        print(error.localizedDescription)
//      }
//    }
//
//    present()
    
    guard let url = viewModels?.first?.file.url else { return }
    print(FileManager.default.validateFolderName(at: url))
  }
}

extension DocumentsPresenter {
  func checkMergeButton(for viewModels: [DocumentsViewModel]?) {
    guard let viewModels = viewModels, !viewModels.isEmpty else {
      // No files/folders to merge, so disable the merge button
      view.display(toolbarButtonAction: .merge, isEnabled: false)
      return
    }
    
    if viewModels.count == 1 {
      // Only one file/folder, so disable the merge button
      view.display(toolbarButtonAction: .merge, isEnabled: false)
    } else {
      let containsFolders = viewModels.contains { $0.file.type == .folder }
      let containsFiles = viewModels.contains { $0.file.type == .file }
      
      if containsFolders && containsFiles {
        // Mixed files and folders, so disable the merge button
        view.display(toolbarButtonAction: .merge, isEnabled: false)
      } else {
        // Only files or only folders, so enable the merge button
        view.display(toolbarButtonAction: .merge, isEnabled: true)
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

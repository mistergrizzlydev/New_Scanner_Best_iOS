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
  
  func onDetailsTapped(_ viewModel: DocumentsViewModel)
  func onShareTapped(_ viewModels: [DocumentsViewModel])
  func onStarredTapped(_ viewModel: DocumentsViewModel)
  func onCopyTapped(_ viewModel: DocumentsViewModel)
  func onMoveTapped(_ viewModels: [DocumentsViewModel])
  func onRenameTapped(_ viewModel: DocumentsViewModel)
  func onDeleteTapped(_ viewModels: [DocumentsViewModel])
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
//    view.share(viewModels.compactMap { $0.file.url })
    let files = viewModels.map { $0.file.url }
    coordinator.presentShare(controller: view, items: files)
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
  
  func onMoveTapped(_ viewModels: [DocumentsViewModel]) {
    // Handle move action
    print("Move action tapped")

    present()
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
    // delete
    
    present()
    
    if viewModels.count < 1 {
      let message = "Files deleted successfully"
      let icon = UIImage(systemName: FileManagerAction.delete.defaultIconName)
      view.showDrop(message: message, icon: icon)
    } else {
      guard let viewModel = viewModels.first else { return }
      let message = viewModel.file.type == .folder ? "Folder deleted successfully" : "File deleted successfully"
      let icon = UIImage(systemName: FileManagerAction.delete.defaultIconName)
      view.showDrop(message: message, icon: icon)
    }
  }
}

import UIKit

protocol DocumentsPresenterProtocol {
  func present()
  func on(sortBy sortType: SortType)
  func didSelect(at index: IndexPath, viewModel: DocumentsViewModel)
  
  var sortedFilesType: SortType { get }
}

final class DocumentsPresenter: DocumentsPresenterProtocol {
  private struct Constants {
    static let title = "My Scans"
  }
  
  private weak var view: (DocumentsViewControllerProtocol & UIViewController)!
  
  let localFileManager: LocalFileManager
  let folder: Folder
  
  init(view: DocumentsViewControllerProtocol & UIViewController,
       localFileManager: LocalFileManager,
       folder: Folder) {
    self.view = view
    self.localFileManager = localFileManager
    self.folder = folder
  }

  func present() {
    if let viewModels = localFileManager.contentsOfDirectory(url: folder.url,
                                                             sortBy: UserDefaults.sortedFilesType)?.compactMap({ DocumentsViewModel(file: $0) }) {
      if localFileManager.isRootDirectory(url: folder.url) {
        view.prepare(with: viewModels, title: Constants.title)
      } else {
        view.prepare(with: viewModels, title: folder.name)
      }
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
    navigateToDocuments(document: viewModel.file)
  }
  
  private func navigateToDocuments(document: Document) {
    switch document.type {
    case .file:
      guard let file = document as? File else { return }
      let controller = DocumentPreviewBuilder().buildViewController(file: file)!
      view.navigationController?.pushViewController(controller, animated: true)
    case .folder:
      guard let folder = document as? Folder else { return }
      let controller = DocumentsBuilder().buildViewController(folder: folder)!
      view.navigationController?.pushViewController(controller, animated: true)
    }
  }
}

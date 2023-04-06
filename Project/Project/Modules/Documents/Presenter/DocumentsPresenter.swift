import UIKit

protocol DocumentsPresenterProtocol {
  func present()
  func didSelect(at index: IndexPath, viewModel: DocumentsViewModel)
}

class DocumentsPresenter: DocumentsPresenterProtocol {
  private weak var view: (DocumentsViewControllerProtocol & UIViewController)!

  let localFileManager: LocalFileManager
  let fileURL: URL
  
  init(view: DocumentsViewControllerProtocol & UIViewController,
       localFileManager: LocalFileManager,
       fileURL: URL) {
    self.view = view
    self.localFileManager = localFileManager
    self.fileURL = fileURL
  }

  func present() {
    // Fetch data or smth else...
    if let viewModels = localFileManager.contentsOfDirectory(url: fileURL)?.compactMap({ DocumentsViewModel(file: $0) }) {
      view.prepare(with: viewModels)
    }
  }
  
  func didSelect(at index: IndexPath, viewModel: DocumentsViewModel) {
    navigateToDocuments(file: viewModel.file)
  }
  
  private func navigateToDocuments(file: Document) {
    switch file.type {
    case .file:
      guard let file = file as? File else { return }
      let controller = DocumentPreviewBuilder().buildViewController(file: file)!
      view.navigationController?.pushViewController(controller, animated: true)
    case .folder:
      let controller = DocumentsBuilder().buildViewController(fileURL: file.url)!
      view.navigationController?.pushViewController(controller, animated: true)
    }
  }
}

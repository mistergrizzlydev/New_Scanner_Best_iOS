import UIKit

protocol ListPresenterProtocol {
  func present()
}

final class ListPresenter: ListPresenterProtocol {
  private struct Constants {
    
  }
  
  private weak var view: (ListViewControllerProtocol & UIViewController)!
  private let coordinator: Coordinator
  private let localFileManager: LocalFileManager
  
  private let rootURL: URL
  private let folders: [URL]
  
  init(view: ListViewControllerProtocol & UIViewController,
       coordinator: Coordinator,
       localFileManager: LocalFileManager,
       rootURL: URL,
       folders: [URL]) {
    self.view = view
    self.coordinator = coordinator
    self.localFileManager = localFileManager
    self.rootURL = rootURL
    self.folders = folders
  }

  func present() {
    let viewModels = folders.compactMap({ ListViewModel(file: Folder(url: $0)) })
    view.prepare(with: viewModels)
  }
}

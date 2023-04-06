import UIKit
import Swinject

protocol DocumentsBuilderProtocol {
  func buildViewController(fileURL: URL) -> DocumentsViewController!
}

class DocumentsBuilder: DocumentsBuilderProtocol {
  private let container = Container(parent: AppContainer.shared.container)
  
  func buildViewController(fileURL: URL) -> DocumentsViewController! {
    container.register(DocumentsViewController.self) { _ in
      DocumentsBuilder.instantiateViewController()
      
    }.initCompleted { r, h in
      h.presenter = r.resolve(DocumentsPresenter.self)
    }
    
    container.register(DocumentsPresenter.self) { c in
      let localFileManager = c.resolve(LocalFileManager.self)!
      
      return DocumentsPresenter(view: c.resolve(DocumentsViewController.self)!,
                                localFileManager: localFileManager,
                                fileURL: fileURL)
    }
    
    return container.resolve(DocumentsViewController.self)!
  }
  
  deinit {
    container.removeAll()
  }
  
  private static func instantiateViewController() -> DocumentsViewController {
    let identifier = String(describing: DocumentsViewController.self)
    let storyboard = UIStoryboard(name: identifier, bundle: .main)
    return storyboard.instantiateViewController(withIdentifier: identifier) as! DocumentsViewController
  }
}

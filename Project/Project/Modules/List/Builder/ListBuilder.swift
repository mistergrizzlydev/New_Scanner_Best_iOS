import UIKit
import Swinject

protocol ListBuilderProtocol {
  func buildViewController(rootURL: URL, folders: [URL]) -> ListViewController!
}

final class ListBuilder: ListBuilderProtocol {
  let container = Container(parent: AppContainer.shared.container)
  
  func buildViewController(rootURL: URL, folders:  [URL]) -> ListViewController! {
    container.register(ListViewController.self) { _ in
      ListBuilder.instantiateViewController()
      
    }.initCompleted { r, h in
      h.presenter = r.resolve(ListPresenter.self)
    }
    
    container.register(ListPresenter.self) { c in
      let localFileManager = c.resolve(LocalFileManager.self)!
      let coordinator = c.resolve(Coordinator.self)!
      
      return ListPresenter(view: c.resolve(ListViewController.self)!,
                           coordinator: coordinator,
                           localFileManager: localFileManager,
                           rootURL: rootURL, folders: folders)
    }
    
    return container.resolve(ListViewController.self)!
  }
  
  deinit {
    container.removeAll()
  }
  
  private static func instantiateViewController() -> ListViewController {
    let identifier = String(describing: ListViewController.self)
    let storyboard = UIStoryboard(name: identifier, bundle: .main)
    return storyboard.instantiateViewController(withIdentifier: identifier) as! ListViewController
  }
}

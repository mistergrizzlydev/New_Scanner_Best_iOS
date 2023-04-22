import UIKit
import Swinject

protocol ListBuilderProtocol {
  func buildViewController(type: ListType, rootURL: URL, filesToMove: [URL]) -> ListViewController!
}

final class ListBuilder: ListBuilderProtocol {
  let container = Container(parent: AppContainer.shared.container)
  
  func buildViewController(type: ListType = .main, rootURL: URL, filesToMove: [URL]) -> ListViewController! {
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
                           type: type,
                           rootURL: rootURL,
                           filesToMove: filesToMove)
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

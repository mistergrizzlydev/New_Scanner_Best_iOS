import UIKit
import Swinject

protocol TabBarBuilderProtocol {
  func buildViewController(with viewControllers: [UIViewController]) -> TabBarViewController!
}

final class TabBarBuilder: TabBarBuilderProtocol {
  let container = Container()
  
  func buildViewController(with viewControllers: [UIViewController]) -> TabBarViewController! {
    container.register(TabBarViewController.self) { _ in
      TabBarBuilder.instantiateViewController(viewControllers: viewControllers)
      
    }.initCompleted { r, h in
      h.presenter = r.resolve(TabBarPresenter.self)
    }
    
    container.register(TabBarPresenter.self) { c in
      TabBarPresenter(view: c.resolve(TabBarViewController.self)!)
    }
    
    return container.resolve(TabBarViewController.self)!
  }
  
  deinit {
    container.removeAll()
  }
  
  private static func instantiateViewController(viewControllers: [UIViewController]) -> TabBarViewController {
    TabBarViewController(viewControllers: viewControllers)
  }
}

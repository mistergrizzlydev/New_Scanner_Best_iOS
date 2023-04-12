import UIKit
import Swinject

protocol StarredBuilderProtocol {
  func buildViewController() -> StarredViewController!
}

class StarredBuilder: StarredBuilderProtocol {
  let container = Container()

  func buildViewController() -> StarredViewController! {
    container.register(StarredViewController.self) { _ in
      StarredBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(StarredPresenter.self)
    }

    container.register(StarredPresenter.self) { c in
      StarredPresenter(view: c.resolve(StarredViewController.self)!)
    }

    return container.resolve(StarredViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> StarredViewController {
    let identifier = String(describing: StarredViewController.self)
    let storyboard = UIStoryboard(name: identifier, bundle: .main)
    return storyboard.instantiateViewController(withIdentifier: identifier) as! StarredViewController
  }
}

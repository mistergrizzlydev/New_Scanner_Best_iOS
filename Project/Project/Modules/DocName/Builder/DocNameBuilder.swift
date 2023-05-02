import UIKit
import Swinject

protocol DocNameBuilderProtocol {
  func buildViewController() -> DocNameViewController!
}

class DocNameBuilder: DocNameBuilderProtocol {
  let container = Container()

  func buildViewController() -> DocNameViewController! {
    container.register(DocNameViewController.self) { _ in
      DocNameBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(DocNamePresenter.self)
    }

    container.register(DocNamePresenter.self) { c in
      DocNamePresenter(view: c.resolve(DocNameViewController.self)!)
    }

    return container.resolve(DocNameViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> DocNameViewController {
    let identifier = String(describing: DocNameViewController.self)
    let storyboard = UIStoryboard(name: identifier, bundle: .main)
    return storyboard.instantiateViewController(withIdentifier: identifier) as! DocNameViewController
  }
}

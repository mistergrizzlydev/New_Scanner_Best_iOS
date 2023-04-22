import UIKit
import Swinject

protocol EditBuilderProtocol {
  func buildViewController() -> EditViewController!
}

class EditBuilder: EditBuilderProtocol {
  let container = Container()

  func buildViewController() -> EditViewController! {
    container.register(EditViewController.self) { _ in
      EditBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(EditPresenter.self)
    }

    container.register(EditPresenter.self) { c in
      EditPresenter(view: c.resolve(EditViewController.self)!)
    }

    return container.resolve(EditViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> EditViewController {
    let identifier = String(describing: EditViewController.self)
    let storyboard = UIStoryboard(name: identifier, bundle: .main)
    return storyboard.instantiateViewController(withIdentifier: identifier) as! EditViewController
  }
}

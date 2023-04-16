import UIKit
import Swinject

protocol TextBuilderProtocol {
  func buildViewController(file: File) -> TextViewController!
}

class TextBuilder: TextBuilderProtocol {
  let container = Container()

  func buildViewController(file: File) -> TextViewController! {
    container.register(TextViewController.self) { _ in
      TextBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(TextPresenter.self)
    }

    container.register(TextPresenter.self) { c in
      TextPresenter(view: c.resolve(TextViewController.self)!, file: file)
    }

    return container.resolve(TextViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> TextViewController {
    let identifier = String(describing: TextViewController.self)
    let storyboard = UIStoryboard(name: identifier, bundle: .main)
    return storyboard.instantiateViewController(withIdentifier: identifier) as! TextViewController
  }
}

import UIKit
import Swinject

protocol OCRLanguagesBuilderProtocol {
  func buildViewController() -> OCRLanguagesViewController!
}

class OCRLanguagesBuilder: OCRLanguagesBuilderProtocol {
  let container = Container()

  func buildViewController() -> OCRLanguagesViewController! {
    container.register(OCRLanguagesViewController.self) { _ in
      OCRLanguagesBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(OCRLanguagesPresenter.self)
    }

    container.register(OCRLanguagesPresenter.self) { c in
      OCRLanguagesPresenter(view: c.resolve(OCRLanguagesViewController.self)!)
    }

    return container.resolve(OCRLanguagesViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> OCRLanguagesViewController {
    OCRLanguagesViewController()
  }
}

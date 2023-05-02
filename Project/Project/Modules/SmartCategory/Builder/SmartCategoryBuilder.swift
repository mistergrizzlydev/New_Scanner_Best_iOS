import UIKit
import Swinject

protocol SmartCategoryBuilderProtocol {
  func buildViewController(file: File) -> SmartCategoryViewController!
}

class SmartCategoryBuilder: SmartCategoryBuilderProtocol {
  let container = Container()

  func buildViewController(file: File) -> SmartCategoryViewController! {
    container.register(SmartCategoryViewController.self) { _ in
      SmartCategoryBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(SmartCategoryPresenter.self)
    }

    container.register(SmartCategoryPresenter.self) { c in
      SmartCategoryPresenter(view: c.resolve(SmartCategoryViewController.self)!, file: file)
    }

    return container.resolve(SmartCategoryViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> SmartCategoryViewController {
    SmartCategoryViewController(collectionViewLayout: UICollectionViewFlowLayout())
  }
}

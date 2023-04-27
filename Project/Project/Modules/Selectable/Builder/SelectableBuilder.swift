import UIKit
import Swinject

protocol SelectableBuilderProtocol {
  func buildViewController(title: String, options: [String], selectedOption: String) -> SelectableViewController!
}

class SelectableBuilder: SelectableBuilderProtocol {
  let container = Container()

  func buildViewController(title: String, options: [String], selectedOption: String) -> SelectableViewController! {
    container.register(SelectableViewController.self) { _ in
      SelectableBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(SelectablePresenter.self)
    }

    container.register(SelectablePresenter.self) { c in
      SelectablePresenter(view: c.resolve(SelectableViewController.self)!, title: title, options: options, selectedOption: selectedOption)
    }

    return container.resolve(SelectableViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> SelectableViewController {
    SelectableViewController()
  }
}

import UIKit

protocol StarredPresenterProtocol {
  func present()
}

class StarredPresenter: StarredPresenterProtocol {
  private weak var view: (StarredViewControllerProtocol & UIViewController)!

  init(view: StarredViewControllerProtocol & UIViewController) {
    self.view = view
  }

  func present() {
    // Fetch data or smth else...
  }
}

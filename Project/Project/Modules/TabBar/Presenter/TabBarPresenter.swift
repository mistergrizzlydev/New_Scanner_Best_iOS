import UIKit

protocol TabBarPresenterProtocol {
  func present()
}

class TabBarPresenter: TabBarPresenterProtocol {
  private weak var view: (TabBarViewControllerProtocol & UIViewController)!

  init(view: TabBarViewControllerProtocol & UIViewController) {
    self.view = view
  }

  func present() { }
}

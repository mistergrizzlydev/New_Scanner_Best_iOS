import UIKit

protocol EditPresenterProtocol {
  func present()
}

class EditPresenter: EditPresenterProtocol {
  private weak var view: (EditViewControllerProtocol & UIViewController)!

  init(view: EditViewControllerProtocol & UIViewController) {
    self.view = view
  }

  func present() {
    // Fetch data or smth else...
  }
}

import UIKit

protocol DocNamePresenterProtocol {
  func present()
}

class DocNamePresenter: DocNamePresenterProtocol {
  private weak var view: (DocNameViewControllerProtocol & UIViewController)!

  init(view: DocNameViewControllerProtocol & UIViewController) {
    self.view = view
  }

  func present() {
    // Fetch data or smth else...
  }
}

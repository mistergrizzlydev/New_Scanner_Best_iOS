import UIKit

protocol DemoVCPresenterProtocol {
  func present()
}

class DemoVCPresenter: DemoVCPresenterProtocol {
  private weak var view: (DemoVCViewControllerProtocol & UIViewController)!

  init(view: DemoVCViewControllerProtocol & UIViewController) {
    self.view = view
  }

  func present() {
    // Fetch data or smth else...
    
  }
}

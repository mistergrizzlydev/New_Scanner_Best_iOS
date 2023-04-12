import UIKit

protocol SettingsPresenterProtocol {
  func present()
}

class SettingsPresenter: SettingsPresenterProtocol {
  private weak var view: (SettingsViewControllerProtocol & UIViewController)!

  init(view: SettingsViewControllerProtocol & UIViewController) {
    self.view = view
  }

  func present() {
    // Fetch data or smth else...
  }
}

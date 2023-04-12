import UIKit

protocol SettingsViewControllerProtocol: AnyObject {
  func prepare(with viewModel: SettingsViewModel)
}

class SettingsViewController: UIViewController, SettingsViewControllerProtocol {
  var presenter: SettingsPresenterProtocol!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }

  private func setupViews() {
    // Setup views
  }

  func prepare(with viewModel: SettingsViewModel) {
    title = viewModel.title
  }
}

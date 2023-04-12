import UIKit

protocol StarredViewControllerProtocol: AnyObject {
  func prepare(with viewModel: StarredViewModel)
}

class StarredViewController: UIViewController, StarredViewControllerProtocol {
  var presenter: StarredPresenterProtocol!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }

  private func setupViews() {
    // Setup views
  }

  func prepare(with viewModel: StarredViewModel) {
    title = viewModel.title
  }
}

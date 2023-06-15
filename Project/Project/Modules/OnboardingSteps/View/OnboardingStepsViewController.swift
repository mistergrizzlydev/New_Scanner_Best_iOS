import UIKit

protocol OnboardingStepsViewControllerProtocol: AnyObject {
  func prepare(with viewModel: OnboardingStepsViewModel)
}

class OnboardingStepsViewController: UIViewController, OnboardingStepsViewControllerProtocol {
  var presenter: OnboardingStepsPresenterProtocol!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }

  private func setupViews() {
    // Setup views
  }

  func prepare(with viewModel: OnboardingStepsViewModel) {
    title = viewModel.title
  }
}

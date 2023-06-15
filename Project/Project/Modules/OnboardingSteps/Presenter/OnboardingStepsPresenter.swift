import UIKit

protocol OnboardingStepsPresenterProtocol {
  func present()
}

class OnboardingStepsPresenter: OnboardingStepsPresenterProtocol {
  private weak var view: (OnboardingStepsViewControllerProtocol & UIViewController)!

  init(view: OnboardingStepsViewControllerProtocol & UIViewController) {
    self.view = view
  }

  func present() {
    // Fetch data or smth else...
  }
}

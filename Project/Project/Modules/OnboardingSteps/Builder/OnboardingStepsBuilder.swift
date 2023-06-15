import UIKit
import Swinject

protocol OnboardingStepsBuilderProtocol {
  func buildViewController() -> OnboardingStepsViewController!
}

class OnboardingStepsBuilder: OnboardingStepsBuilderProtocol {
  let container = Container()

  func buildViewController() -> OnboardingStepsViewController! {
    container.register(OnboardingStepsViewController.self) { _ in
      OnboardingStepsBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(OnboardingStepsPresenter.self)
    }

    container.register(OnboardingStepsPresenter.self) { c in
      OnboardingStepsPresenter(view: c.resolve(OnboardingStepsViewController.self)!)
    }

    return container.resolve(OnboardingStepsViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> OnboardingStepsViewController {
    let identifier = String(describing: OnboardingStepsViewController.self)
    let storyboard = UIStoryboard(name: identifier, bundle: .main)
    return storyboard.instantiateViewController(withIdentifier: identifier) as! OnboardingStepsViewController
  }
}

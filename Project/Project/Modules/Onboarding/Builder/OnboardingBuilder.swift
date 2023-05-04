import UIKit
import Swinject

protocol OnboardingBuilderProtocol {
  func buildViewController() -> OnboardingViewController!
}

final class OnboardingBuilder: OnboardingBuilderProtocol {
  private let container = Container(parent: AppContainer.shared.container)
  
  func buildViewController() -> OnboardingViewController! {
    container.register(OnboardingViewController.self) { _ in
      OnboardingBuilder.instantiateViewController()
      
    }.initCompleted { r, h in
      h.presenter = r.resolve(OnboardingPresenter.self)
    }
    
    container.register(OnboardingPresenter.self) { c in
      let localFileManager = c.resolve(LocalFileManager.self)!
      let coordinator = c.resolve(Coordinator.self)!
      
      return OnboardingPresenter(view: c.resolve(OnboardingViewController.self)!,
                                 coordinator: coordinator,
                                 localFileManager: localFileManager)
    }
    
    return container.resolve(OnboardingViewController.self)!
  }
  
  deinit {
    container.removeAll()
  }
  
  private static func instantiateViewController() -> OnboardingViewController {
    let identifier = String(describing: OnboardingViewController.self)
    let storyboard = UIStoryboard(name: identifier, bundle: .main)
    return storyboard.instantiateViewController(withIdentifier: identifier) as! OnboardingViewController
  }
}

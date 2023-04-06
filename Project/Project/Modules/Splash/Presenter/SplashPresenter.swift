import UIKit

protocol SplashPresenterProtocol {
  func present()
}

class SplashPresenter: SplashPresenterProtocol {
  private weak var view: (SplashViewControllerProtocol & UIViewController)!
  let localFileManager: LocalFileManager
  
  init(view: SplashViewControllerProtocol & UIViewController,
       localFileManager: LocalFileManager) {
    self.view = view
    self.localFileManager = localFileManager
  }

  func present() {
    // Fetch data or smth else...
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      // Code to be executed after 1 second delay
      debugPrint("navigateToOnboarding")
      
      if UserDefaults.isOnboarded {
        self.navigateToDocuments()
      } else {
        self.navigateToOnboarding()
      }
    }
  }
  
  private func navigateToOnboarding() {
    let controller = OnboardingBuilder().buildViewController()!
    controller.modalPresentationStyle = .fullScreen
    view.present(controller, animated: true)
  }
  
  private func navigateToDocuments() {
    let controller = DocumentsBuilder().buildViewController(fileURL: localFileManager.getDocumentsURL())!
    let navigation = BaseNavigationController(rootViewController: controller)
    navigation.modalPresentationStyle = .fullScreen
    view.present(navigation, animated: false)
  }
}

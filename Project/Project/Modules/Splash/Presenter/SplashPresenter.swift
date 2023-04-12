import UIKit

protocol SplashPresenterProtocol {
  func present()
}

final class SplashPresenter: SplashPresenterProtocol {
  private weak var view: (SplashViewControllerProtocol & UIViewController)!
  let localFileManager: LocalFileManager
  let coordinator: Coordinator
  
  init(view: SplashViewControllerProtocol & UIViewController,
       coordinator: Coordinator,
       localFileManager: LocalFileManager) {
    self.view = view
    self.coordinator = coordinator
    self.localFileManager = localFileManager
  }
  
  func present() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self = self else { return }
      if UserDefaults.isOnboarded {
        let folder = Folder(url: self.localFileManager.getDocumentsURL())
        self.coordinator.navigateToDocuments(folder: folder)
      } else {
        self.coordinator.navigateToOnboarding()
      }
    }
  }
}

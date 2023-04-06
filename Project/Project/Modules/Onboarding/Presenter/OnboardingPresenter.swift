import UIKit

protocol OnboardingPresenterProtocol {
  func present()
  
  func onCategoryTapped(_ category: OnboardingCategory)
}

final class OnboardingPresenter: OnboardingPresenterProtocol {
  private weak var view: (OnboardingViewControllerProtocol & UIViewController)!
  let localFileManager: LocalFileManager
  
  init(view: OnboardingViewControllerProtocol & UIViewController, localFileManager: LocalFileManager) {
    self.view = view
    self.localFileManager = localFileManager
  }
  
  func present() {
    let viewModel = OnboardingViewModel(title: "Who are you?",
                                        skip: "Skip",
                                        done: "Finish",
                                        categories: OnboardingCategory.allCases.sorted(by: < ))
    view.prepare(with: viewModel)
  }
  
  func onCategoryTapped(_ category: OnboardingCategory) {
    view.showLoadingView(title: "Loading...")
    
    do {
      try localFileManager.createFolders(for: category)
      UserDefaults.isOnboarded = true
    } catch {
      debugPrint(error.localizedDescription)
    }
    
    view.dismissLoadingView(after: 2.0) {
      self.navigateToDocuments()
    }
  }
  
  private func navigateToDocuments() {
    let controller = DocumentsBuilder().buildViewController(fileURL: localFileManager.getDocumentsURL())!
    let navigation = BaseNavigationController(rootViewController: controller)
    navigation.modalPresentationStyle = .fullScreen
    view.present(navigation, animated: false)
  }
}

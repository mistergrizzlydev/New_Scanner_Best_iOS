import UIKit

protocol OnboardingPresenterProtocol {
  func present()
  
  func onCategoryTapped(_ category: OnboardingCategory)
}

final class OnboardingPresenter: OnboardingPresenterProtocol {
  private weak var view: (OnboardingViewControllerProtocol & UIViewController)!
  let coordinator: Coordinator
  let localFileManager: LocalFileManager

  init(view: OnboardingViewControllerProtocol & UIViewController,
       coordinator: Coordinator,
       localFileManager: LocalFileManager) {
    self.view = view
    self.coordinator = coordinator
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
    UserDefaults.onboardingCategory = category
    
    do {
      try localFileManager.createFolders(for: category)
      UserDefaults.isOnboarded = true
    } catch {
      debugPrint(error.localizedDescription)
    }
    
    view.dismissLoadingView(after: 2.0) { [weak self] in
      guard let self = self else { return }
      self.coordinator.navigateToDocuments(folder: Folder(url: self.localFileManager.getDocumentsURL()))
    }
  }
}

import UIKit

protocol SmartCategoryPresenterProtocol {
  func present()
  func didSelectOnCategory(at index: Int)
}

final class SmartCategoryPresenter: SmartCategoryPresenterProtocol {
  private weak var view: (SmartCategoryViewControllerProtocol & UIViewController)!

  init(view: SmartCategoryViewControllerProtocol & UIViewController) {
    self.view = view
  }

  func present() {
    let viewModels = DocumentClasifierCategory.allCases.compactMap { SmartCategoryViewModel(category: $0)}
    view.prepare(with: viewModels)
  }
  
  func didSelectOnCategory(at index: Int) {
    let selectedCategory = DocumentClasifierCategory.allCases.compactMap { SmartCategoryViewModel(category: $0)}[index]
    UserDefaults.documentClasifierCategory = selectedCategory.category
    present()
  }
}

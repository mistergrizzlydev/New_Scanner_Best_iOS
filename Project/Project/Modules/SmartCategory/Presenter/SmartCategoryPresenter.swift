import UIKit

protocol SmartCategoryPresenterProtocol {
  func present()
  func didSelectOnCategory(at index: Int)
}

final class SmartCategoryPresenter: SmartCategoryPresenterProtocol {
  private weak var view: (SmartCategoryViewControllerProtocol & UIViewController)!
  private let file: File
  
  init(view: SmartCategoryViewControllerProtocol & UIViewController, file: File) {
    self.view = view
    self.file = file
  }

  func present() {
    let viewModels = DocumentClasifierCategory.allCases.compactMap { SmartCategoryViewModel(category: $0, key: file.name)}
    view.prepare(with: viewModels)
  }
  
  func didSelectOnCategory(at index: Int) {
    let selectedCategory = DocumentClasifierCategory.allCases.compactMap { SmartCategoryViewModel(category: $0, key: file.name)}[index]
//    UserDefaults.documentClasifierCategory = selectedCategory.category
    UserDefaults.setSmartCategory(selectedCategory.category, name: file.name)
      NotificationCenter.default.post(name: .smartCategorySelected, object: nil)
      view.dismiss(animated: true)
  }
}

extension Notification.Name {
  static let smartCategorySelected = Notification.Name("SmartCategorySelected")
}

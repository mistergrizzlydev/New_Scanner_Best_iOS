import UIKit

protocol SelectablePresenterProtocol {
  func present()
  func didSelect(at indexPath: IndexPath, selectedOption: String)
}

final class SelectablePresenter: SelectablePresenterProtocol {
  private weak var view: (SelectableViewControllerProtocol & UIViewController)!
  private let options: [String]
  private var selectedOption: String
  private let title: String
  
  init(view: SelectableViewControllerProtocol & UIViewController,
       title: String, options: [String], selectedOption: String) {
    self.view = view
    self.options = options
    self.selectedOption = selectedOption
    self.title = title
  }
  
  func present() {
    // Fetch data or smth else...
    let viewModel = SelectableViewModel(title: title, options: options, selectedOption: selectedOption)
    view.prepare(with: viewModel)
  }
  
  func didSelect(at indexPath: IndexPath, selectedOption: String) {
    if let appearance = Appearance(rawValue: selectedOption.lowercased()) {
      appearance.apply()
    }
    
    if let pageSize = PageSize(rawValue: selectedOption) ?? PageSize(rawValue: selectedOption.lowercased())  {
      UserDefaults.pageSize = pageSize
    }
    
    if let imageCompressionLevel = ImageSize(rawValue: selectedOption.lowercased()) {
      UserDefaults.imageCompressionLevel = imageCompressionLevel
    }
    
    NotificationCenter.default.post(name: .selectableScreenDidSelectOption, object: nil)
  }
}

extension Notification.Name {
  static let selectableScreenDidSelectOption = Notification.Name("SelectableScreenDidSelectOption")
}

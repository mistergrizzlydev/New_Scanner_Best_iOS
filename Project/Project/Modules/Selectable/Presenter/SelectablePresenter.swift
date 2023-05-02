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
    
    if let startType = StartType(rawValue: selectedOption) {
      UserDefaults.startType = startType
    }
    
    if let sortType = SortType(rawValue: selectedOption) {
      UserDefaults.sortedFilesType = sortType
    }
    
    if let smartCategory = DocumentClasifierCategory(classification: selectedOption) {
      UserDefaults.documentClasifierCategory = smartCategory
    }
      
      if let cameraFlashType = CameraFlashType(rawValue: indexPath.row) {
        UserDefaults.cameraFlashType = cameraFlashType
      }
      
      if let cameraFilterType = CameraFilterType(rawValue: indexPath.row) {
        UserDefaults.cameraFilterType = cameraFilterType
      }
      
      if let documentDetectionType = DocumentDetectionType(rawValue: indexPath.row) {
        UserDefaults.documentDetectionType = documentDetectionType
      }
    
    NotificationCenter.default.post(name: .selectableScreenDidSelectOption, object: nil)
  }
}

extension Notification.Name {
  static let selectableScreenDidSelectOption = Notification.Name("SelectableScreenDidSelectOption")
}

import UIKit

enum SortType: String {
  case date = "Date"
  case name = "Name"
  case size = "Size"
  case foldersOnTop = "Folders on top"
  
  private static let imageConfig = UIImage.SymbolConfiguration(pointSize: 23, weight: .regular)
  
  var image: UIImage {
    switch self {
    case .date: return .systemCalendar()
    case .name: return .systemSize()
    case .size: return .systemTextformat()
    case .foldersOnTop: return .systemFolder()
    }
  }
  
  var settingsImage: UIImage {
    switch self {
    case .date: return .systemCalendar(with: SortType.imageConfig)
    case .name: return .systemSize(with: SortType.imageConfig)
    case .size: return .systemTextformat(with: SortType.imageConfig)
    case .foldersOnTop: return .systemFolder(with: SortType.imageConfig)
    }
  }
  
  static var allCases: [SortType] {
    [.date, .name, .size, .foldersOnTop]
  }
}

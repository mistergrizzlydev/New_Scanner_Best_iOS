import Foundation

enum SearchScope: String {
  case all = "All"
  case files = "Files"
  case folders = "Folders"
  
  static var allCases: [SearchScope] {
    [.all, .folders, .files]
  }
  
  init(index: Int) {
    switch index {
    case 0:
      self = .all
    case 1:
      self = .folders
    default:
      self = .files
    }
  }
}

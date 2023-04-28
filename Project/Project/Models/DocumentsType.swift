import UIKit

enum DocumentsType {
  case myScans
  case starred
  
  var title: String {
    switch self {
    case .myScans: return "My Scans"
    case .starred: return "Starred Documents"
    }
  }
  
  var tabBarItemName: String {
    switch self {
    case .myScans: return "My Scans"
    case .starred: return "Starred"
    }
  }
  
  var image: UIImage {
    switch self {
    case .myScans: return .systemFolder()
    case .starred: return .systemStar()
    }
  }
}

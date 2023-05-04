import UIKit

enum DocumentDetectionType: Int {
  case auto = 0
  case manual
  
  var name: String {
    switch self {
    case .auto:
      return "Auto"
    case .manual:
      return "Manual"
    }
  }
  
  var imageName: String {
    switch self {
    case .auto:
      return "doc.viewfinder.fill"
    case .manual:
      return "doc.viewfinder"
    }
  }
  
  static var allCases: [DocumentDetectionType] {
    [.auto, .manual]
  }
}

extension UserDefaults {
  static var documentDetectionType: DocumentDetectionType {
    get {
      let result = standard.integer(forKey: "documentDetectionType")
      return DocumentDetectionType(rawValue: result) ?? .auto
    }
    set {
      standard.set(newValue.rawValue, forKey: "documentDetectionType")
      standard.synchronize()
    }
  }
}

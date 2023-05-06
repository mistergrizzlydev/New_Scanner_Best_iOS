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
      let result = standard.integer(forKey: "c676b8e3-7eba-4323-96aa-598752132233")
      return DocumentDetectionType(rawValue: result) ?? .auto
    }
    set {
      standard.set(newValue.rawValue, forKey: "c676b8e3-7eba-4323-96aa-598752132233")
      standard.synchronize()
    }
  }
}

import Foundation

enum CameraFlashType: Int {
  case auto = 0
  case on
  case off
  
  var name: String {
    switch self {
    case .auto:
      return "Auto"
    case .on:
      return "On"
    case .off:
      return "Off"
    }
  }
  
  var imageName: String {
    switch self {
    case .auto:
      return "bolt.badge.a.fill"
    case .on:
      return "bolt.fill"
    case .off:
      return "bolt.slash.fill"
    }
  }
  
  static var allCases: [CameraFlashType] {
    [.auto, .on, .off]
  }
}

extension UserDefaults {
  static var cameraFlashType: CameraFlashType {
    get {
      let result = standard.integer(forKey: "2b8d85fd-6c44-46c6-9dc5-a972d77d9aff")
      return CameraFlashType(rawValue: result) ?? .auto
    }
    set {
      standard.set(newValue.rawValue, forKey: "2b8d85fd-6c44-46c6-9dc5-a972d77d9aff")
      standard.synchronize()
    }
  }
}

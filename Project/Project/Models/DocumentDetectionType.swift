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


enum CameraFilterType: Int {
    case color = 0
    case grayscale
    case bw
    case photo
    
    var name: String {
        switch self {
        case .color:
            return "Color"
        case .grayscale:
            return "GrayScale"
        case .bw:
            return "Black & White"
        case .photo:
            return "Photo"
        }
    }
    
    static var allCases: [CameraFilterType] {
        [.color, .grayscale, .bw, .photo]
    }
}

extension UserDefaults {
    static var cameraFilterType: CameraFilterType {
      get {
          let result = standard.integer(forKey: "cameraFilterType")
          return CameraFilterType(rawValue: result) ?? .color
      }
      set {
        standard.set(newValue.rawValue, forKey: "cameraFilterType")
        standard.synchronize()
      }
    }
}


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
          let result = standard.integer(forKey: "cameraFlashType")
          return CameraFlashType(rawValue: result) ?? .auto
      }
      set {
        standard.set(newValue.rawValue, forKey: "cameraFlashType")
        standard.synchronize()
      }
    }
}

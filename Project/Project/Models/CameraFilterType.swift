import Foundation

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
      let result = standard.integer(forKey: "138526ea-12fc-494a-85cf-3886b3ca1fbb")
      return CameraFilterType(rawValue: result) ?? .color
    }
    set {
      standard.set(newValue.rawValue, forKey: "138526ea-12fc-494a-85cf-3886b3ca1fbb")
      standard.synchronize()
    }
  }
}

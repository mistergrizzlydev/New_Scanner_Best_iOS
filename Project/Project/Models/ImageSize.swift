import UIKit
import Sandwich

enum ImageSize: String {
  case low
  case medium
  case small
  case original
  
  var name: String {
    rawValue.capitalized
  }
  
  var sizeValue: CGFloat {
    switch self {
    case .low:
      return 0.25
    case .medium:
      return 0.5
    case .small:
      return 0.75
    case .original:
      return 1.0
    }
  }
  
  static var allCases: [ImageSize] {
    [.small, .low, .medium, .original]
  }

  func compressionLevel() -> CompressionLevel {
    switch self {
    case .low, .small:
      return .low
    case .medium:
      return .medium
    case .original:
      return .original
    }
  }
}

extension UIImage {
  func jpegData(size: ImageSize) -> Data? {
    jpegData(compressionQuality: size.sizeValue)
  }
}

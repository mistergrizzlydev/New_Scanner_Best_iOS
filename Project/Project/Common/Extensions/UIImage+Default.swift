import UIKit

extension UIImage {
  // Default images
  private enum DefaultImageName: String {
    case fullFolder = "full-folder"
    case emptyFolder = "empty-folder"
    
    case file
  }
  
  class var fullFolder: UIImage {
    guard let image = UIImage(named: DefaultImageName.fullFolder.rawValue) else {
      fatalError("Cannot find \(DefaultImageName.fullFolder.rawValue) in Assets.xcassets file. Please add it back.")
    }
    
    return image
  }
  
  class var emptyFolder: UIImage {
    guard let image = UIImage(named: DefaultImageName.emptyFolder.rawValue) else {
      fatalError("Cannot find \(DefaultImageName.emptyFolder.rawValue) in Assets.xcassets file. Please add it back.")
    }
    
    return image
  }
  
  class var file: UIImage {
    guard let image = UIImage(named: DefaultImageName.file.rawValue) else {
      fatalError("Cannot find \(DefaultImageName.file.rawValue) in Assets.xcassets file. Please add it back.")
    }
    
    return image
  }
}

extension UIImage {
  /// Tint Image
  ///
  /// - Parameter fillColor: UIColor
  /// - Returns: Image with tint color
  func tint(with fillColor: UIColor) -> UIImage? {
    let image = withRenderingMode(.alwaysTemplate)
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    fillColor.set()
    image.draw(in: CGRect(origin: .zero, size: size))
    
    guard let imageColored = UIGraphicsGetImageFromCurrentImageContext() else {
      return nil
    }
    
    UIGraphicsEndImageContext()
    return imageColored
  }
}

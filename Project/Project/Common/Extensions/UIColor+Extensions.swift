import UIKit

extension UIColor {
  private enum Color: String{
    case themeColor, bgColor, labelColor, labelTextColor
  }
  
  class var themeColor: UIColor {
    guard let color = UIColor(named: Color.themeColor.rawValue) else {
      fatalError("Cannot find \(Color.themeColor.rawValue) in Colors.xcassets file. Please add it back.")
    }
    
    return color
  }
  
  class var bgColor: UIColor {
    guard let color = UIColor(named: Color.bgColor.rawValue) else {
      fatalError("Cannot find \(Color.bgColor.rawValue) in Colors.xcassets file. Please add it back.")
    }
    
    return color
  }
  
  class var labelColor: UIColor {
    guard let color = UIColor(named: Color.labelColor.rawValue) else {
      fatalError("Cannot find \(Color.labelColor.rawValue) in Colors.xcassets file. Please add it back.")
    }
    
    return color
  }
  
  class var labelTextColor: UIColor {
    guard let color = UIColor(named: Color.labelTextColor.rawValue) else {
      fatalError("Cannot find \(Color.labelTextColor.rawValue) in Colors.xcassets file. Please add it back.")
    }
    
    return color
  }
}

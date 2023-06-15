import UIKit

extension UIColor {
  private enum Color: String{
    case themeColor, bgColor, labelColor, labelTextColor, themeGreen, themeBlick, themeSelectedColor, themeLigthGray
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
  
  class var themeGreen: UIColor {
    guard let color = UIColor(named: Color.themeGreen.rawValue) else {
      fatalError("Cannot find \(Color.themeGreen.rawValue) in Colors.xcassets file. Please add it back.")
    }
    
    return color
  }
  
  class var themeBlick: UIColor {
    guard let color = UIColor(named: Color.themeBlick.rawValue) else {
      fatalError("Cannot find \(Color.themeBlick.rawValue) in Colors.xcassets file. Please add it back.")
    }
    
    return color
  }
  
  class var themeSelectedColor: UIColor {
    guard let color = UIColor(named: Color.themeSelectedColor.rawValue) else {
      fatalError("Cannot find \(Color.themeSelectedColor.rawValue) in Colors.xcassets file. Please add it back.")
    }
    
    return color
  }
  
  class var themeLigthGray: UIColor {
    guard let color = UIColor(named: Color.themeLigthGray.rawValue) else {
      fatalError("Cannot find \(Color.themeLigthGray.rawValue) in Colors.xcassets file. Please add it back.")
    }
    
    return color
  }
}

extension UIColor {
  class func colorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
}

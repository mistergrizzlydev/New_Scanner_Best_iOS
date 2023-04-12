//
//  UIColor+Extensions.swift
//  Project
//
//  Created by Mister Grizzly on 07.04.2023.
//

import UIKit

extension UIColor {
  private enum Color: String{
    case themeColor
  }
  
  class var themeColor: UIColor {
    guard let color = UIColor(named: Color.themeColor.rawValue) else {
      fatalError("Cannot find \(Color.themeColor.rawValue) in Colors.xcassets file. Please add it back.")
    }
    
    return color
  }
}

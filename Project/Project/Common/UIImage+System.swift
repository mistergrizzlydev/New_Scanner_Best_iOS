//
//  UIImage+System.swift
//  Project
//
//  Created by Mister Grizzly on 08.04.2023.
//

import UIKit

extension UIImage {
  // System images
  private enum SystemImageName: String {
    case plus
    case plusCircle = "plus.circle"
    case ellipsisCircle = "ellipsis.circle"
    case calendar, textformat, folder
    case folderFull = "folder.fill"
    case addFolder = "folder.badge.plus"
    case size = "arrow.up.arrow.down"
    case share = "square.and.arrow.up"
    case annotate = "pencil.tip.crop.circle.badge.plus"
    case edit = "pencil.and.outline"
    case textSearch = "doc.text.magnifyingglass"
    case settings = "gearshape.fill" // "gear.badge"
    case star = "star.fill"
  }
  
  class func systemFolderFull(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.folderFull.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.folderFull.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemStar(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.star.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.star.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemSettings(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.settings.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.settings.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemAddFolder(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.addFolder.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.addFolder.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemTextSearch(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.textSearch.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.textSearch.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemEdit(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.edit.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.edit.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemAnnotate(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.annotate.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.annotate.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemPlus(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.plus.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.plus.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemShare(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.share.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.share.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemEllipsisCircle(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.ellipsisCircle.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.ellipsisCircle.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemCalendar(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.calendar.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.calendar.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemTextformat(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.textformat.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.textformat.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemFolder(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.folder.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.folder.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
  
  class func systemSize(with config: UIImage.SymbolConfiguration? = nil) -> UIImage {
    guard let image = UIImage(systemName: SystemImageName.size.rawValue,
                              withConfiguration: config) else {
      fatalError("Cannot find \(SystemImageName.size.rawValue) in font system. Please investigate the issue.")
    }
    
    return image
  }
}



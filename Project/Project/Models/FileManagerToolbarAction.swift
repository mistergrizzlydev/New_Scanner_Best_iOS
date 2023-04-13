//
//  FileManagerToolbarAction.swift
//  Project
//
//  Created by Mister Grizzly on 14.04.2023.
//

import UIKit

enum FileManagerToolbarAction: Int {
  case share = 0
  case merge
  case move
  case delete
  
  private func barButtonItem(target: Any?, action: Selector?) -> UIBarButtonItem {
    switch self {
    case .share:
      let item = UIBarButtonItem(barButtonSystemItem: .action, target: target, action: action)
      item.tag = rawValue
      return item
    case .merge:
      let mergeImage = UIImage(systemName: "arrow.right.arrow.left")?.withRenderingMode(.alwaysTemplate)
      let mergeButton = UIBarButtonItem(image: mergeImage, style: .plain, target: target, action: action)
      mergeButton.tag = rawValue
      return mergeButton
    case .move:
      let moveImage = UIImage(systemName: "folder")?.withRenderingMode(.alwaysTemplate)
      let moveButton = UIBarButtonItem(image: moveImage, style: .plain, target: target, action: action)
      moveButton.tag = rawValue
      return moveButton
    case .delete:
      let item = UIBarButtonItem(barButtonSystemItem: .trash, target: target, action: action)
      item.tag = rawValue
      return item
    }
  }
  
  private static var flexibleSpace: UIBarButtonItem {
      return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
  }
  
  static func toolbarItems(target: Any?, action: Selector?) -> [UIBarButtonItem] {
    return [
      FileManagerToolbarAction.share.barButtonItem(target: target, action: action),
      FileManagerToolbarAction.flexibleSpace,
      FileManagerToolbarAction.merge.barButtonItem(target: target, action: action),
      FileManagerToolbarAction.flexibleSpace,
      FileManagerToolbarAction.move.barButtonItem(target: target, action: action),
      FileManagerToolbarAction.flexibleSpace,
      FileManagerToolbarAction.delete.barButtonItem(target: target, action: action)
    ]
  }
}

//
//  UIMenu+Extensions.swift
//  Project
//
//  Created by Mister Grizzly on 12.04.2023.
//

import UIKit

extension UIMenu {
  static func updateActionState(actionTitle: String? = nil, menu: UIMenu) -> UIMenu {
    if let actionTitle = actionTitle {
      menu.children.forEach { action in
        guard let childMenu = action as? UIMenu else {
          return
        }
        
        childMenu.children.forEach { action in
          guard let action = action as? UIAction else {
            return
          }
          action.state = action.title == actionTitle ? .on : .off
        }
      }
    } else {
      let action = menu.children.first as? UIAction
      action?.state = .on
    }
    return menu
  }
}

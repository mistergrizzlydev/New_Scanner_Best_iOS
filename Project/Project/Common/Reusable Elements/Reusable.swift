//
//  Reusable.swift
//  Project
//
//  Created by Mister Grizzly on 15.04.2023.
//

import UIKit

protocol Reusable {
  static var reuseIdentifier: String { get }
}

extension Reusable {
  static var reuseIdentifier: String {
    return String(describing: Self.self)
  }
}

extension UITableViewCell: Reusable {}
extension UICollectionViewCell: Reusable {}

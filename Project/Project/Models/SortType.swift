//
//  SortType.swift
//  Project
//
//  Created by Mister Grizzly on 07.04.2023.
//

import UIKit

enum SortType: String {
  case date = "Date"
  case name = "Name"
  case size = "Size"
  case foldersOnTop = "Folders on top"

  var image: UIImage {
    switch self {
    case .date: return .systemCalendar()
    case .name: return .systemSize()
    case .size: return .systemTextformat()
    case .foldersOnTop: return .systemFolder()
    }
  }
  
  static var allCases: [SortType] {
    [.date, .name, .size, .foldersOnTop]
  }
}

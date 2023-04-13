//
//  FileManagerAction.swift
//  Project
//
//  Created by Mister Grizzly on 14.04.2023.
//

import UIKit

enum FileManagerAction: Int, CaseIterable {
  case rename = 0
  case move
  case copy
  case star
  case share
  case properties

  var title: String {
    switch self {
    case .rename: return "Rename"
    case .move: return "Move to"
    case .copy: return "Copy"
    case .star: return "Add to Starred"
    case .share: return "Share"
    case .properties: return "View details"
    }
  }
  
  var iconName: String {
    switch self {
    case .rename: return "pencil"
    case .move: return "arrowshape.turn.up.left"
    case .copy: return "doc.on.doc"
    case .star: return "star"
    case .share: return "square.and.arrow.up"
    case .properties: return "info.circle"
    }
  }
}

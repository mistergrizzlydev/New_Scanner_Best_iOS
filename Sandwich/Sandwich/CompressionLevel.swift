//
//  CompressionLevel.swift
//  Sandwich
//
//  Created by Mister Grizzly on 09.04.2023.
//

import Foundation

public enum CompressionLevel: Int {
  case low = 0
  case medium = 1
  case high = 2
  case veryHigh = 3
  case original = 4
  
  public var compressionQuality: CGFloat {
    switch self {
    case .low:
      return 0.3
    case .medium:
      return 0.4
    case .high:
      return 0.5
    case .veryHigh:
      return 0.6
    case .original:
      return 1.0
    }
  }
  
  var baseHeight: Float {
    switch self {
    case .low:
      return 1190.4    // A4 * 2
    case .medium:
      return 1785.6    // A4 * 3
    case .high:
      return 2380.8    // A4 * 4
    case .veryHigh:
      return 2976.0    // A4 * 5
    case .original:
      return 0.0      // no resizing
    }
  }
  var baseWidth: Float {
    switch self {
    case .low:
      return 1683.6    // A4 * 2
    case .medium:
      return 2525.4    // A4 * 3
    case .high:
      return 3367.2    // A4 * 4
    case .veryHigh:
      return 4209.0    // A4 * 5
    case .original:
      return 0.0      // no resizing
    }
  }
}

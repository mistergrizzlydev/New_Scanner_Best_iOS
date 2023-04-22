//
//  UserDefaults+Extensions.swift
//  Project
//
//  Created by Mister Grizzly on 06.04.2023.
//

import Foundation

extension UserDefaults {
  static var isOnboarded: Bool {
    get {
      return standard.bool(forKey: "isOnboarded")
    }
    set {
      standard.set(newValue, forKey: "isOnboarded")
      standard.synchronize()
    }
  }
  
  static var sortedFilesType: SortType {
    get {
      guard let result = standard.string(forKey: "sortedFilesType") else { return .name }
      return SortType(rawValue: result) ?? .name
    }
    set {
      standard.set(newValue.rawValue, forKey: "sortedFilesType")
      standard.synchronize()
    }
  }
}

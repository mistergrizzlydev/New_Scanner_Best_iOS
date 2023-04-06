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
}

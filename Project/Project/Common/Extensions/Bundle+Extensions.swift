//
//  Bundle+Extensions.swift
//  Project
//
//  Created by Mister Grizzly on 14.04.2023.
//

import Foundation

extension Bundle {
  var appName: String? {
    return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? object(forInfoDictionaryKey: "CFBundleName") as? String
  }
}

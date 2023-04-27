import Foundation

extension UserDefaults {
  
  /// Check if the app is launched for the first time on the device.
  /// - Returns: A Boolean value indicating whether the app is launched for the first time or not.
  func isFirstLaunch() -> Bool {
    let key = "isFirstLaunch"
    if !bool(forKey: key) {
      set(true, forKey: key)
      synchronize()
      return true
    }
    return false
  }
}


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
  
  static var appearance: Appearance {
    get {
      guard let result = standard.string(forKey: "appearance") else { return .system }
      return Appearance(rawValue: result) ?? .system
    }
    set {
      standard.set(newValue.rawValue.lowercased(), forKey: "appearance")
      standard.synchronize()
    }
  }
  
  static var imageCompressionLevel: ImageSize {
    get {
      guard let result = standard.string(forKey: "imageCompressionLevel") else { return .medium }
      return ImageSize(rawValue: result) ?? .medium
    }
    set {
      standard.set(newValue.rawValue.lowercased(), forKey: "imageCompressionLevel")
      standard.synchronize()
    }
  }
  
  static var pageSize: PageSize {
    get {
      guard let result = standard.string(forKey: "pageSize") else { return .auto }
      return PageSize(rawValue: result) ?? .auto
    }
    set {
      standard.set(newValue.rawValue, forKey: "pageSize")
      standard.synchronize()
    }
  }
  
  static var isOCREnabled: Bool {
    get {
      return standard.bool(forKey: "isOCREnabled")
    }
    set {
      standard.set(newValue, forKey: "isOCREnabled")
      standard.synchronize()
    }
  }
  
  static var isDistorsionEnabled: Bool {
    get {
      return standard.bool(forKey: "isDistorsionEnabled")
    }
    set {
      standard.set(newValue, forKey: "isDistorsionEnabled")
      standard.synchronize()
    }
  }
  
  static var isCameraStabilizationEnabled: Bool {
    get {
      return standard.bool(forKey: "isCameraStabilizationEnabled")
    }
    set {
      standard.set(newValue, forKey: "isCameraStabilizationEnabled")
      standard.synchronize()
    }
  }
}

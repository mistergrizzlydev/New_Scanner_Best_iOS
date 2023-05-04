import Foundation

extension UserDefaults {
  
  /// Check if the app is launched for the first time on the device.
  /// - Returns: A Boolean value indicating whether the app is launched for the first time or not.
  func isFirstLaunch() -> Bool {
    let key = "1092c6f1-d8fd-4e15-98d8-e1be1c9a87bf"
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
      return standard.bool(forKey: "9467185c-ba35-402f-a4fa-b3eee9b01c461")
    }
    set {
      standard.set(newValue, forKey: "9467185c-ba35-402f-a4fa-b3eee9b01c461")
      standard.synchronize()
    }
  }
  
  static var sortedFilesType: SortType {
    get {
      guard let result = standard.string(forKey: "6f25807a-c014-4635-83e5-45283e89d726")?.decrypted else { return .name }
      return SortType(rawValue: result) ?? .name
    }
    set {
      standard.set(newValue.rawValue.encrypted, forKey: "6f25807a-c014-4635-83e5-45283e89d726")
      standard.synchronize()
    }
  }
  
  static var onboardingCategory: OnboardingCategory {
    get {
      let result = standard.integer(forKey: "9ff8f2e0-0c08-4f45-ba71-cecde13516df")
      return OnboardingCategory(rawValue: result) ?? .skip
    }
    set {
      standard.set(newValue.rawValue, forKey: "9ff8f2e0-0c08-4f45-ba71-cecde13516df")
      standard.synchronize()
    }
  }
  
  static var appearance: Appearance {
    get {
      guard let result = standard.string(forKey: "1df65e88-2dbd-403f-9f95-7a9dcbe778ab")?.decrypted else { return .system }
      return Appearance(rawValue: result) ?? .system
    }
    set {
      standard.set(newValue.rawValue.lowercased().encrypted, forKey: "1df65e88-2dbd-403f-9f95-7a9dcbe778ab")
      standard.synchronize()
    }
  }
  
  static var imageCompressionLevel: ImageSize {
    get {
      guard let result = standard.string(forKey: "9ac1a189-3a5d-4cc5-b397-8743bda55018")?.decrypted else { return .medium }
      return ImageSize(rawValue: result) ?? .medium
    }
    set {
      standard.set(newValue.rawValue.lowercased().encrypted, forKey: "9ac1a189-3a5d-4cc5-b397-8743bda55018")
      standard.synchronize()
    }
  }
  
  static var pageSize: PageSize {
    get {
      guard let result = standard.string(forKey: "e51b9902-b284-4f35-bd55-ca28d37472ec")?.decrypted else { return .auto }
      return PageSize(rawValue: result) ?? .auto
    }
    set {
      standard.set(newValue.rawValue.encrypted, forKey: "e51b9902-b284-4f35-bd55-ca28d37472ec")
      standard.synchronize()
    }
  }

  static var startType: StartType {
    get {
      guard let result = standard.string(forKey: "2a9721d5-4652-4917-a5b5-fed97ec0c1bf")?.decrypted else { return .myFiles }
      return StartType(rawValue: result) ?? .myFiles
    }
    set {
      standard.set(newValue.rawValue.encrypted, forKey: "2a9721d5-4652-4917-a5b5-fed97ec0c1bf")
      standard.synchronize()
    }
  }
  
  static var wasStartTypeLaunched: Bool {
    get {
      return standard.bool(forKey: "e8ee97be-93a7-485d-a9b2-c89e6046133e")
    }
    set {
      standard.set(newValue, forKey: "e8ee97be-93a7-485d-a9b2-c89e6046133e")
      standard.synchronize()
    }
  }
  
  static var documentClasifierCategory: DocumentClasifierCategory {
    get {
      let result = standard.integer(forKey: "ee77d129-389a-4f8f-a8b8-150c973c2127")
      return DocumentClasifierCategory(rawValue: result) ?? .invoice
    }
    set {
      standard.set(newValue.rawValue, forKey: "ee77d129-389a-4f8f-a8b8-150c973c2127")
      standard.synchronize()
    }
  }
  
  static func setSmartCategory(_ category: DocumentClasifierCategory, name: String) {
    debugPrint("setSmartCategory ", name)
    standard.set(category.rawValue, forKey: name)
    standard.synchronize()
  }
  
  static func getSmartCategory(name: String) -> DocumentClasifierCategory? {
    debugPrint("getSmartCategory ", name)
    let result = standard.integer(forKey: name)
    return DocumentClasifierCategory(rawValue: result)
  }
  
  static var isOCREnabled: Bool {
    get {
      return standard.bool(forKey: "45a7b1bd-770a-400b-9140-2fe9f7af18cb")
    }
    set {
      standard.set(newValue, forKey: "45a7b1bd-770a-400b-9140-2fe9f7af18cb")
      standard.synchronize()
    }
  }
  
  static var isDistorsionEnabled: Bool {
    get {
      return standard.bool(forKey: "bfc2af2f-dc74-4662-b388-ed57710c19c9")
    }
    set {
      standard.set(newValue, forKey: "bfc2af2f-dc74-4662-b388-ed57710c19c9")
      standard.synchronize()
    }
  }
  
  static var isCameraStabilizationEnabled: Bool {
    get {
      return standard.bool(forKey: "b4a60b5a-d690-43d9-a95e-35df90a56b67")
    }
    set {
      standard.set(newValue, forKey: "b4a60b5a-d690-43d9-a95e-35df90a56b67")
      standard.synchronize()
    }
  }
  
  static var emailFromAccount: String {
    get {      
      standard.string(forKey: "71290833-5d75-424e-a399-49f5441ef25b")?.decrypted ?? ""
    }
    set {
      standard.set(newValue.encrypted, forKey: "71290833-5d75-424e-a399-49f5441ef25b")
      standard.synchronize()
    }
  }
}

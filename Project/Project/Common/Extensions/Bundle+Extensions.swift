import UIKit

extension Bundle {
  var appName: String? {
    return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? object(forInfoDictionaryKey: "CFBundleName") as? String
  }
}

extension Bundle {
  static var appVersion: String {
    guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
          let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
      return "Unknown"
    }
    return "\(version) (\(build))"
  }
  
  static var deviceModel: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let modelCode = withUnsafePointer(to: &systemInfo.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: 1) {
        ptr in String.init(validatingUTF8: ptr)
      }
    }
    return modelCode ?? "Unknown"
  }
  
  static var iOSVersion: String {
    return UIDevice.current.systemVersion
  }
}

extension Bundle {
  class var appName: String {
    return main.appName ?? ""
  }
  
  class var versionNumber: String? {
    return appVersion
  }
  
  class var fullVersionString: String {
    return appVersion
  }
}

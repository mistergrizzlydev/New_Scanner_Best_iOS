import Security
import UIKit

final class KeychainManager {
  static let `default` = KeychainManager()
  
  
  
  private init() {
    
  }
  
  func saveBool(_ value: Bool, forKey key: String) {
    let data = Data([value ? 1 : 0])
    saveData(data, forKey: key)
  }
  
  func getBool(forKey key: String) -> Bool? {
    guard let data = getData(forKey: key), let byte = data.first else {
      return nil
    }
    return byte == 1
  }
  
  func saveInt(_ value: Int, forKey key: String) {
    let data = Data(value.toBytes())
    saveData(data, forKey: key)
  }
  
  func getInt(forKey key: String) -> Int? {
    guard let data = getData(forKey: key), data.count == MemoryLayout<Int>.size else {
      return nil
    }
    return data.withUnsafeBytes { $0.load(as: Int.self) }
  }
  
  func saveString(_ value: String, forKey key: String) {
    guard let data = value.data(using: .utf8) else {
      return
    }
    saveData(data, forKey: key)
  }
  
  func getString(forKey key: String) -> String? {
    guard let data = getData(forKey: key) else {
      return nil
    }
    return String(data: data, encoding: .utf8)
  }
  
  private func saveData(_ data: Data, forKey key: String) {
    let query = [kSecClass: kSecClassGenericPassword,
           kSecAttrAccount: key,
             kSecValueData: data] as CFDictionary
    SecItemAdd(query, nil)
  }
  
  private func getData(forKey key: String) -> Data? {
    let query = [kSecClass: kSecClassGenericPassword,
           kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne] as CFDictionary
    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(query, &dataTypeRef)
    guard status == errSecSuccess, let data = dataTypeRef as? Data else {
      return nil
    }
    return data
  }
  
}

private extension BinaryInteger {
  func toBytes() -> [UInt8] {
    var value = self
    return withUnsafeBytes(of: &value, Array.init)
  }
}

extension KeychainManager {
  var isAppLocked: Bool {
    get {
      getBool(forKey: "isAppLocked") ?? false
    }
    set {
      saveBool(newValue, forKey: "isAppLocked")
    }
  }
}

import Foundation

struct AppManager {
  static var isProVersion: Bool {
    return PurchaseManager.shared.isProVersion
  }
}

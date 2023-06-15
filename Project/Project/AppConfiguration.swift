import UIKit

let deviceType = UIDevice.current.userInterfaceIdiom
let isiPhone = deviceType == .phone

struct AppConfiguration {
    enum OCR {
        static let personalKey = "K6THam-YqqTcU-WTWSde-qaayNa-cDqMLc-gLH"
    }
    
  enum Help: String {
    case support = "newturboscanapp@gmail.com "
    case featureRequeast = "newturboscanapp@gmail.com"
    case tellAFriend = "Hey! 👋 You have to try TurboScan™ in your smartphone! Is the powerfull mobile scanner app EVER! \nDownload it for free 😃"
    case privacyPolicy = "https://turboscan.xcellent.app/privacy-policy.html"
    case terms = "https://turboscan.xcellent.app/terms-of-use.html"
  }
  
  enum AppStore: String {
    case id = "6447110239"
    case moreApps = "https://apps.apple.com/us/developer/mihail-salari/id1263980303?see-all=i-phonei-pad-apps"
  }
  
  static func appStoreURL(with id: String) -> String {
    return "https://apps.apple.com/app/id\(id)"
  }
}

func delay(_ seconds: Double, completion: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

import UIKit

extension UIWindow {
  static var key: UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap({ $0.windows })
      .first(where: { $0.isKeyWindow })
  }
}

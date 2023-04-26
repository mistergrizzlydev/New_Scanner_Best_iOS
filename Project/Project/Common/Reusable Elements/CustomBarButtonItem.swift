import UIKit

class CustomBarButtonItem: UIBarButtonItem {
  convenience init(image: UIImage?, title: String?, target: Any?, action: Selector?) {
    let button = CenteredButton(type: .system)
    button.setImage(image, for: .normal)
    button.setTitle(title, for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.setTitleColor(.lightGray, for: .highlighted)
    self.init(customView: button)
    self.target = target as AnyObject?
    self.action = action
  }
}

extension UIBarButtonItem {
  static func barButtonItem(withImage image: UIImage?, title: String?, target: Any?, action: Selector?) -> UIBarButtonItem {
    return CustomBarButtonItem(image: image, title: title, target: target, action: action)
  }
}

import UIKit

extension UIView {
  func transformAndHide() {
    transform = CGAffineTransform(translationX: 0, y: 50)
    alpha = 0.0
  }
  
  func showAndChangeTransformBack(delay: TimeInterval, alpha: CGFloat = 1.0) {
    UIView.animate(withDuration: 0.5, delay: delay, options: [.curveEaseOut], animations: { [weak self] in
      self?.transform = CGAffineTransform.identity
      self?.alpha = alpha
    }, completion: nil)
  }
}

extension UIView {
  func allSubviews() -> [UIView] {
    var subviews = [UIView]()
    iterateThroughAllSubviews { subview in
      subviews.append(subview)
    }
    return subviews
  }
  
  private func iterateThroughAllSubviews(_ body: (UIView) -> Void) {
    body(self)
    subviews.forEach {
      $0.iterateThroughAllSubviews(body)
    }
  }
}

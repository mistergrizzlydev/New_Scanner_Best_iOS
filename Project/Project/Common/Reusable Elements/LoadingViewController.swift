import UIKit

final class LoadingViewController: UIViewController {
  private let activityIndicatorView = UIActivityIndicatorView(style: .large)
  private let label = UILabel()
  private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
  
  private var titleText: String
  
  init(titleText: String = "Loading...") {
    self.titleText = titleText
    super.init(nibName: nil, bundle: nil)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    // Configure the blur effect view
    blurEffectView.frame = view.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    // Configure the activity indicator view
    activityIndicatorView.center = view.center
    activityIndicatorView.hidesWhenStopped = true
    activityIndicatorView.tintColor = .labelColor
    activityIndicatorView.hidesWhenStopped = true
    activityIndicatorView.color = .labelColor
    
    // Configure the label
    label.textColor = .labelColor
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 16)
    label.numberOfLines = 0
    label.text = titleText
    label.sizeToFit()
    label.center = CGPoint(x: view.center.x, y: view.center.y + 40)
    
    // Add the views to the view hierarchy
    view.addSubview(blurEffectView)
    view.addSubview(activityIndicatorView)
    view.addSubview(label)
  }
  
  func show(animated: Bool = true) {
    activityIndicatorView.startAnimating()
    blurEffectView.alpha = 0
    view.alpha = 0
    
    if animated {
      UIView.animate(withDuration: 0.3) {
        self.view.alpha = 1
        self.blurEffectView.alpha = 1
      }
    } else {
      view.alpha = 1
      blurEffectView.alpha = 1
    }
  }
  
  func hideLoading(animated: Bool = true, after delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
    let delayTime = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
      if animated {
        UIView.animate(withDuration: 0.3, animations: {
          self.view.alpha = 0
          self.blurEffectView.alpha = 0
        }) { _ in
          self.activityIndicatorView.stopAnimating()
          self.dismiss(animated: false, completion: completion)
        }
      } else {
        self.activityIndicatorView.stopAnimating()
        self.dismiss(animated: false, completion: completion)
      }
    }
  }
}

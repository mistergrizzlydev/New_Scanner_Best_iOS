import UIKit

final class LoadingViewController: UIViewController {
  
  private let activityIndicatorView = UIActivityIndicatorView(style: .large)
  private let label = UILabel()
  private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
  
  var titleText: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Configure the blur effect view
    blurEffectView.frame = view.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    // Configure the activity indicator view
    activityIndicatorView.center = view.center
    activityIndicatorView.hidesWhenStopped = true
    activityIndicatorView.tintColor = .red
    activityIndicatorView.hidesWhenStopped = true
    
    // Configure the label
    label.textColor = .black
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 16)
    label.numberOfLines = 0
    label.text = "Loading..."
    label.sizeToFit()
    label.center = CGPoint(x: view.center.x, y: view.center.y + 40)
    
    // Add the views to the view hierarchy
    view.addSubview(blurEffectView)
    view.addSubview(activityIndicatorView)
    view.addSubview(label)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let titleText = titleText {
      self.title = titleText
    }
  }
  
  func setTitle(_ title: String?) {
    self.titleText = title
    if isViewLoaded {
      self.title = title
    }
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

/*
 final class LoadingViewController: UIViewController {
 private let activityIndicatorView = UIActivityIndicatorView(style: .large)
 private let label = UILabel()
 var titleText: String?
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 view.backgroundColor = .white
 view.alpha = 0.7
 
 activityIndicatorView.color = .gray
 activityIndicatorView.startAnimating()
 activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
 
 label.textAlignment = .center
 label.font = UIFont.systemFont(ofSize: 16)
 label.textColor = .gray
 label.text = "Loading..."
 label.translatesAutoresizingMaskIntoConstraints = false
 
 view.addSubview(activityIndicatorView)
 view.addSubview(label)
 
 NSLayoutConstraint.activate([
 activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
 activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
 label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
 label.topAnchor.constraint(equalTo: activityIndicatorView.bottomAnchor, constant: 10)
 ])
 }
 
 override func viewWillAppear(_ animated: Bool) {
 super.viewWillAppear(animated)
 if let titleText = titleText {
 self.title = titleText
 }
 }
 
 func setTitle(_ title: String?) {
 self.titleText = title
 if isViewLoaded {
 self.title = title
 }
 }
 }
 */

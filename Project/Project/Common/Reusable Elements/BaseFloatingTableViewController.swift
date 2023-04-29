import UIKit

class BaseFloatingTableViewController: UITableViewController {
  private let stackView = FloatingStackView()
  
  var cameraButtonTapped: (() -> Void)?
  var galleryButtonTapped: (() -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let buttonSpacing: CGFloat = 8
    let buttonSize: CGFloat = 44
    
    if let view = UIWindow.key {
      stackView.accessibilityIdentifier = "floatingStackView"
      view.addSubview(stackView)
      stackView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64),
        stackView.heightAnchor.constraint(equalToConstant: buttonSize),
        stackView.widthAnchor.constraint(equalToConstant: (buttonSize * 2) + buttonSpacing + 1)
      ])
    }
    
    stackView.cameraButtonTapped = { [weak self] in
      self?.cameraButtonTapped?()
    }
    stackView.galleryButtonTapped = { [weak self] in
      self?.galleryButtonTapped?()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    stackView.isHidden = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stackView.isHidden = true
  }
}

extension BaseFloatingTableViewController {
  func showHideFloatingStackView(isHidden: Bool) {
    UIView.animate(withDuration: 0.3) {
      if isHidden {
        // Move the stack view down to the bottom of the screen
        self.stackView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height - self.stackView.frame.origin.y)
        // Set the stack view's alpha to 0 to make it disappear
        self.stackView.alpha = 0.0
      } else {
        // Move the stack view back up to its original position
        self.stackView.transform = .identity
        // Set the stack view's alpha back to 1.0 to make it reappear
        self.stackView.alpha = 1.0
      }
    }
  }
}

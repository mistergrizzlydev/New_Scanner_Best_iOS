import UIKit

class BaseFloatingTableViewController: UITableViewController {
  private let stackView = FloatingStackView()
  private var floatingView: UIView? {
    UIWindow.key?.allSubviews().first(where: { $0.accessibilityIdentifier == "floatingView" })
  }
  
  var cameraButtonTapped: (() -> Void)?
  var galleryButtonTapped: (() -> Void)?
  
  private func addFloatingView() {
    let buttonSize: CGFloat = 44
    
    if let allSubviews = UIWindow.key?.allSubviews().filter({ $0.accessibilityIdentifier == "floatingView" }) {
      for view in allSubviews {
        view.removeFromSuperview()
      }
    }
    
    if let view = UIWindow.key {
      let floatingView = UIView(frame: .zero)
      floatingView.accessibilityIdentifier = "floatingView"
      floatingView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(floatingView)
      
      floatingView.layer.cornerRadius = 18.0
      floatingView.layer.applySketchShadow()
      
      NSLayoutConstraint.activate([
        floatingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        floatingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -68),
        floatingView.heightAnchor.constraint(equalToConstant: buttonSize)
      ])
      
      stackView.translatesAutoresizingMaskIntoConstraints = false
      floatingView.addSubview(stackView)
      
      NSLayoutConstraint.activate([
        stackView.trailingAnchor.constraint(equalTo: floatingView.trailingAnchor),
        stackView.bottomAnchor.constraint(equalTo: floatingView.bottomAnchor),
        stackView.topAnchor.constraint(equalTo: floatingView.topAnchor),
        stackView.leadingAnchor.constraint(equalTo: floatingView.leadingAnchor)
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
    addFloatingView()
    stackView.isHidden = false
    floatingView?.isHidden = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    floatingView?.removeFromSuperview()
  }
}

extension BaseFloatingTableViewController {
  func showHideFloatingStackView(isHidden: Bool) {
    UIView.animate(withDuration: 0.3) { [weak self] in
      guard let self = self, let floatingView = self.floatingView else { return }
      if isHidden {
        // Move the stack view down to the bottom of the screen
        floatingView.transform = CGAffineTransform(translationX: 0,
                                                   y: self.view.bounds.height - floatingView.frame.origin.y)
        // Set the stack view's alpha to 0 to make it disappear
        floatingView.alpha = 0.0
      } else {
        // Move the stack view back up to its original position
        floatingView.transform = .identity
        // Set the stack view's alpha back to 1.0 to make it reappear
        floatingView.alpha = 1.0
      }
    }
  }
}

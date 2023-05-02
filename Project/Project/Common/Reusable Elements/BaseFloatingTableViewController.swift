import UIKit

class BaseFloatingTableViewController: UITableViewController {
    private let stackView = FloatingStackView()
    private var floatingView: UIView?
    
    var cameraButtonTapped: (() -> Void)?
    var galleryButtonTapped: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let buttonSize: CGFloat = 44
        
        if let view = UIWindow.key {
            floatingView = UIView(frame: .zero)
            floatingView?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(floatingView!)
            
            floatingView!.layer.cornerRadius = 18.0
            floatingView!.layer.applySketchShadow()
            
            NSLayoutConstraint.activate([
                floatingView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
                floatingView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64),
                floatingView!.heightAnchor.constraint(equalToConstant: buttonSize)
            ])
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            floatingView?.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.trailingAnchor.constraint(equalTo: floatingView!.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: floatingView!.bottomAnchor),
                stackView.topAnchor.constraint(equalTo: floatingView!.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: floatingView!.leadingAnchor)
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
        floatingView?.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stackView.isHidden = true
        floatingView?.isHidden = true
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

extension CALayer {
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0)
    {
        masksToBounds = false
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

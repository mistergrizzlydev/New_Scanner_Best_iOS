import Vision
import VisionKit
import UIKit

final class DocumentScannerController: VNDocumentCameraViewController {
    func pressButtons() {
        delay(2) { [weak self] in// 0.33 default
            guard let self = self else { return }
//            print(documentScannerViewController.view.allSubviews())
            debugPrint("has flash:", UIDevice.hasFlash())

            self.getButton(with: UserDefaults.cameraFilterType.name)?.sendActions(for: .touchUpInside)

            if UIDevice.hasFlash() {
                switch UserDefaults.cameraFlashType {
                case .auto:
                    (self.view.allSubviews().filter { $0 is UIButton } as? [UIButton])?.filter { $0.titleLabel?.text?.lowercased() == "auto" }
                        .first(where: { $0.frame.origin.x == 0 })?.sendActions(for: .touchUpInside)
                case .off, .on:
                    self.getButton(with: UserDefaults.cameraFlashType.name)?.sendActions(for: .touchUpInside)
                }
                
                switch UserDefaults.documentDetectionType {
                case .auto:
                    (self.view.allSubviews()
                        .filter { $0 is UIButton } as? [UIButton])?.filter { $0.titleLabel?.text?.lowercased() == "auto" }
                        .first(where: { $0.frame.origin.x != 0 })?.sendActions(for: .touchUpInside)
                case .manual:
                    (self.view.allSubviews().filter { $0 is UIButton } as? [UIButton])?
                        .first(where: { $0.titleLabel?.text?.lowercased() == "manual"})?.sendActions(for: .touchUpInside)
                }
            } else {
                delay(1) { [weak self] in
                    // on ipad needs a delay more
                    guard let self = self else { return }
                    switch UserDefaults.documentDetectionType {
                    case .auto:
                        (self.view.allSubviews().filter { $0 is UIButton } as? [UIButton])?
                            .first(where: { $0.titleLabel?.text?.lowercased() == "auto"})?.sendActions(for: .touchUpInside)
                    case .manual:
                        (self.view.allSubviews().filter { $0 is UIButton } as? [UIButton])?
                            .first(where: { $0.titleLabel?.text?.lowercased() == "manual"})?.sendActions(for: .touchUpInside)
                    }
                }
            }
        }
    }
    
    func addHintView() {
//        delay(3) { [weak self] in// 0.33 default
//            guard let self = self else { return }
            
//            let aaa = ChildViewController()
//            self.addController(controller: aaa, containerView: self.view)
//            self.present(aaa, animated: true)
            
            
            // works
//            let controller = UIViewController()
//            controller.view.backgroundColor = .red
//
//            if let sheet = controller.sheetPresentationController {
//              sheet.detents = [.medium()]
//              sheet.prefersGrabberVisible = true
//              //        sheet.smallestUndimmedDetentIdentifier = .medium
//              sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//              //        sheet.preferredCornerRadius = 30.0
//            }
//
//            self.present(controller, animated: true)
//        }
    }
    
    func showLabels() {
        let label = BorderLabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.backgroundColor = .bgColor
        label.textColor = .themeColor
        label.alpha = 0
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 160), // added
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor), // commented (removed from center)
            label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8)
        ])

        delay(1) {
            UIView.animate(withDuration: 2, animations: {
                label.alpha = 1.0
                label.text = UserDefaults.isCameraStabilizationEnabled ? "Camera Stabilization On" : "Camera Stabilization Off"
            }, completion: { finished in
                if finished {
                    label.alpha = 0.0
                }
            })
        }
        
        delay(3) {
            UIView.animate(withDuration: 2, animations: {
                label.alpha = 1.0
                label.text = UserDefaults.isDistorsionEnabled ? "Distorsion On" : "Distorsion Off"
            }, completion: { finished in
                if finished {
                    label.alpha = 0.0
                }
            })
        }
    }
    
    @objc func closeButtonTapped() {
        
    }
}

extension DocumentScannerController {
    private func getButton(with title: String) -> UIButton? {
        (view.allSubviews()
            .filter { $0 is UIButton } as? [UIButton])?
            .first(where: { $0.titleLabel?.text?.lowercased() == title.lowercased() })
    }
    
    /*
     let colorButton = (self.view.allSubviews().filter { $0 is UIButton } as? [UIButton])?.first(where: { $0.titleLabel?.text?.lowercased() == "color"})
//            colorButton?.sendActions(for: .touchUpInside) // works
     
     let grayscaleButton = (self.view.allSubviews().filter { $0 is UIButton } as? [UIButton])?.first(where: { $0.titleLabel?.text?.lowercased() == "grayscale"})
//            grayscaleButton?.sendActions(for: .touchUpInside) // works
     
     let bwButton = (self.view.allSubviews().filter { $0 is UIButton } as? [UIButton])?.first(where: { $0.titleLabel?.text?.lowercased() == "black & white"})
//            bwButton?.sendActions(for: .touchUpInside) // works
     
     let photoButton = (self.view.allSubviews().filter { $0 is UIButton } as? [UIButton])?.first(where: { $0.titleLabel?.text?.lowercased() == "photo"})
//            photoButton?.sendActions(for: .touchUpInside) // works
     */
    
    /*
    let filterAuto = (self.view.allSubviews().filter { $0 is UIButton } as? [UIButton])?.filter { $0.titleLabel?.text?.lowercased() == "auto" }.first(where: { $0.frame.origin.x == 0 })
    filterAuto?.sendActions(for: .touchUpInside) // works
    
    let onButton = (self.view.allSubviews().filter { $0 is UIButton } as? [UIButton])?.first(where: { $0.titleLabel?.text?.lowercased() == "on"})
//            onButton?.sendActions(for: .touchUpInside) // works
    
    let offButton = (self.view.allSubviews().filter { $0 is UIButton } as? [UIButton])?.first(where: { $0.titleLabel?.text?.lowercased() == "off"})
//            offButton?.sendActions(for: .touchUpInside) // works
    */
    
    /*
     let cancelButton = (self.view.allSubviews().filter { $0 is UIButton } as? [UIButton])?.first(where: { $0.titleLabel?.text?.lowercased() == "cancel"})
//            cancelButton?.sendActions(for: .touchUpInside) // works
     */
}

extension UIViewController {

    // Add a child view controller, its whole view is embeded in the containerView
    func addController(controller: UIViewController, containerView: UIView) {
        if let parent = controller.parent, parent == self {
            return
        }
        addChild(controller)
        controller.view.frame = CGRect.init(origin: .zero, size: CGSize(width: 200, height: 200))
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
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

//func delay(_ delay: Double, closure: @escaping () -> Void) {
//    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: closure)
//}

import UIKit

class ParentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // Create the child view controller
//        let childVC = ChildViewController()
//        addChild(childVC)
//        view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
//        view.backgroundColor = .gray
//        view.layer.cornerRadius = 12
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOpacity = 0.5
//        view.layer.shadowOffset = CGSize(width: 0, height: 2)
//        view.layer.shadowRadius = 2
//        didMove(toParent: self)
//
//        // Add a label with some dummy text in the middle
//        let label = UILabel()
//        label.text = "Dummy Text"
//        label.textAlignment = .center
//        view.addSubview(label)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//
//        // Add a close button in the top right corner
//        let closeButton = UIButton()
//        closeButton.setTitle("X", for: .normal)
//        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
//        view.addSubview(closeButton)
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
//        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
//        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
//        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
//
//        // Present the child view controller
//        present(childVC, animated: true, completion: nil)
    }
}

class ChildViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        view.backgroundColor = .gray
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 2
        didMove(toParent: self)
        
        // Add a label with some dummy text in the middle
        let label = UILabel()
        label.text = "Dummy Text"
        label.textAlignment = .center
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Add a close button in the top right corner
        let closeButton = UIButton()
        closeButton.setTitle("X", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

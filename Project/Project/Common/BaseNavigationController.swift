//
//  BaseNavigationController.swift
//  Project
//
//  Created by Mister Grizzly on 06.04.2023.
//

import UIKit

final class BaseNavigationController: UINavigationController {
  private var floatingButton: UIButton?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
    
    // Customize the navigation bar appearance
    navigationBar.barTintColor = .white
    navigationBar.tintColor = .themeColor
    navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    
    // Hide the back button title
    let appearance = UIBarButtonItem.appearance()
    appearance.setTitleTextAttributes([.foregroundColor: UIColor.themeColor], for: .normal)
    appearance.setTitleTextAttributes([.foregroundColor: UIColor.themeColor.withAlphaComponent(0.5)], for: .highlighted)
    
    // Set the appearance of the navigation bar when it is scrolled to the top
//      let scrollEdgeAppearance = UINavigationBarAppearance()
//      scrollEdgeAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//      scrollEdgeAppearance.backgroundColor = UIColor.blue
//      navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
    
  
    floatingButton = UIButton(type: .system)
    floatingButton?.accessibilityIdentifier = "floatingButton"
    floatingButton?.addTarget(self, action: #selector(handleFloatingButtonTap), for: .touchUpInside)
    guard let floatingButton = floatingButton else { return }
    // Add the floating button to the view controller's view
    view.addSubview(floatingButton)
    
    // Set up the button's appearance
    floatingButton.backgroundColor = .white
    floatingButton.layer.cornerRadius = 25.0
    
    let image = UIImage.systemPlus(with: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large))
    floatingButton.setImage(image, for: .normal)
    floatingButton.tintColor = .black
    floatingButton.imageView?.contentMode = .scaleAspectFit
    
    floatingButton.layer.shadowColor = UIColor.black.cgColor
    floatingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
    floatingButton.layer.shadowOpacity = 0.4
    floatingButton.layer.shadowRadius = 4
    
    // Set up the button's constraints to center it on the screen
    floatingButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      floatingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.0),
      floatingButton.widthAnchor.constraint(equalToConstant: 50.0),
      floatingButton.heightAnchor.constraint(equalToConstant: 50.0)
    ])
    
    // Customize the cancel button's appearance
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print(1112222)
  }
  
//  override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//    super.pushViewController(viewController, animated: animated)
//
//    // Hide the floating button if the pushed view controller is not `DocumentsViewController`
//    if !(viewController is DocumentsViewController) {
//      floatingButton?.isHidden = true
//    } else {
//      floatingButton?.isHidden = false
//    }
//  }
  
  override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    // Check if the view controller being pushed is a subclass of BaseViewController
    if let baseViewController = viewController as? DocumentsViewController {
      // Set the hidesBottomBarWhenPushed property based on the value of showTabBar property
      baseViewController.hidesBottomBarWhenPushed = false//!baseViewController.navigationController?.toolbar.isHidden
    } else if let preview = viewController as? DocumentPreviewViewController {
      preview.hidesBottomBarWhenPushed = true
    }
    
    if !(viewController is DocumentsViewController) {
      floatingButton?.isHidden = true
    } else {
      floatingButton?.isHidden = false
    }
    
    // Call the super method to push the view controller onto the stack
    super.pushViewController(viewController, animated: animated)
  }
  
  // Handle the floating button's tap event
  @objc private func handleFloatingButtonTap() {
    // Do something when the button is tapped
    print(111)
  }
}

extension UINavigationController {
  func getFloatingButton() -> UIButton? {
    if self is BaseNavigationController {
      return view.subviews.first(where: { $0.accessibilityIdentifier == "floatingButton"}) as? UIButton
    }
    
    return nil
  }
}

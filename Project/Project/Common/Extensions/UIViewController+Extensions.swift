//
//  UIViewController+Extensions.swift
//  Project
//
//  Created by Mister Grizzly on 06.04.2023.
//

import UIKit

extension UIViewController {
  private static var loadingViewControllerKey = "loadingViewControllerKey"
  
  private var loadingViewController: LoadingViewController? {
    get {
      return objc_getAssociatedObject(self, &UIViewController.loadingViewControllerKey) as? LoadingViewController
    }
    set {
      objc_setAssociatedObject(self, &UIViewController.loadingViewControllerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  func showLoadingView(title: String? = nil) {
    if loadingViewController == nil {
      let loadingViewController = LoadingViewController()
      loadingViewController.modalPresentationStyle = .overCurrentContext
      self.loadingViewController = loadingViewController
    }
    loadingViewController?.setTitle(title)
    loadingViewController?.show()
    present(loadingViewController!, animated: false)
    
  }
  
  func dismissLoadingView(after delay: TimeInterval = 0.0, completion: (() -> Void)? = nil) {
    loadingViewController?.hideLoading(after: delay, completion: completion)
    loadingViewController = nil
  }
}

extension UIViewController {
  func setTabBarItem(title: String?, image: UIImage?, selectedImage: UIImage?, tag: Int) {
    self.title = title
    self.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
    self.tabBarItem.tag = tag
  }
}

extension UIViewController {
  func wrappedInNavigation(title: String?, image: UIImage, tabBarItemName: String, tag: Int) -> UIViewController {
    tabBarItem = UITabBarItem(title: tabBarItemName, image: image, tag: tag)
    self.navigationItem.title = title
    
    return self
  }
}

extension UIViewController {
  func presentAlert(withTitle title: String? = Bundle.main.appName, message: String?, alerts: [UIAlertAction],
                    preferredStyle: UIAlertController.Style = .alert,
                    animated: Bool = true, completion: (() -> Void)? = nil) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    
    for alert in alerts {
      alertController.addAction(alert)
    }
    
    present(alertController, animated: animated, completion: completion)
  }
  
  func presentAlertWithTextField(title: String? = Bundle.main.appName, message: String?,
                                 placeholder: String?,
                                 confirmAction: ((String) -> Void)?,
                                 cancelAction: (() -> Void)? = nil) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    alertController.addTextField { textField in
      textField.placeholder = placeholder
    }
    
    let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
      guard let textField = alertController?.textFields?.first,
            let text = textField.text,
            !text.isEmpty else { return }
      
      confirmAction?(text)
    }
    alertController.addAction(confirmAction)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      cancelAction?()
    }
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true)
  }
}

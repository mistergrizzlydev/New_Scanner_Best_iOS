//
//  UIViewController+Extensions.swift
//  Project
//
//  Created by Mister Grizzly on 06.04.2023.
//

import UIKit

extension UIViewController {
  private static var loadingViewControllerKey = "loadingViewControllerKey"
  
  var loadingViewController: LoadingViewController? {
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

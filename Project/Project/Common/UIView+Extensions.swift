//
//  UIView+Extensions.swift
//  Project
//
//  Created by Mister Grizzly on 06.04.2023.
//

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

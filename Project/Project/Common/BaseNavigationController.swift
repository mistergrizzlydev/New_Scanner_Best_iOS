//
//  BaseNavigationController.swift
//  Project
//
//  Created by Mister Grizzly on 06.04.2023.
//

import UIKit

final class BaseNavigationController: UINavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationBar.prefersLargeTitles = true
    
    // Customize the navigation bar appearance
    navigationBar.barTintColor = .white
    navigationBar.tintColor = .blue
    navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    
    // Hide the back button title
    let appearance = UIBarButtonItem.appearance()
    appearance.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
    appearance.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .highlighted)
  }
}

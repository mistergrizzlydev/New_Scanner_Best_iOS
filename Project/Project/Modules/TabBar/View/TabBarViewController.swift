import UIKit

protocol TabBarViewControllerProtocol: AnyObject {
  init(viewControllers: [UIViewController])
}

class TabBarViewController: UITabBarController, TabBarViewControllerProtocol {
  var presenter: TabBarPresenterProtocol!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter?.present()
  }

  required init(viewControllers: [UIViewController]) {
    let viewControllers = viewControllers.compactMap { BaseNavigationController(rootViewController: $0) }
    super.init(nibName: nil, bundle: nil)
    self.viewControllers = viewControllers
    
    // Add a shadow to the tab bar
//           tabBar.layer.shadowColor = UIColor.black.cgColor
//           tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
//           tabBar.layer.shadowOpacity = 0.5
//           tabBar.layer.shadowRadius = 3
           
           // Add a line above the tab bar
    let lineView = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width * 2, height: 0.5))
    lineView.backgroundColor = .gray
    tabBar.addSubview(lineView)
    
    tabBar.tintColor = UIColor.themeColor
    
    self.setViewControllers(viewControllers, animated: true)
    
    self.delegate = self
  }
  
  required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  @objc func plusButtonTapped() {
      // Handle the tap event of the plus button
  }
}

extension UITabBarController {
  func showHideTabBar(_ editing: Bool, animated: Bool) {
    let tabBarheight = tabBar.frame.size.height
    if animated {
      UIView.animate(withDuration: 0.3) { [weak self] in
        guard let self = self else { return }
        // adjust the frame of the tab bar to animate the hiding/showing
        if editing {
          self.tabBar.frame.origin.y += tabBarheight
        } else {
          self.tabBar.frame.origin.y -= tabBarheight
        }
      }
    } else {
      // adjust the frame of the tab bar without animation
      if editing {
        self.tabBar.frame.origin.y += tabBarheight
      } else {
        self.tabBar.frame.origin.y -= tabBarheight
      }
    }
  }
}

extension TabBarViewController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    //          if let index = tabBarController.viewControllers?.firstIndex(of: viewController), index == 1 {
    //              // Second tab bar item was selected
    //              // Do something here
    //          }    
//    if let floatingButton = (viewController as? BaseNavigationController)?.getFloatingButton() {
//      floatingButton.alpha = 1
//    }
    
//    if let baseNavigationController = viewController as? BaseNavigationController {
//      baseNavigationController.showHideFloatingButton(false, animated: true)
//    }
  }
}

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
  }
  
  required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  @objc func plusButtonTapped() {
      // Handle the tap event of the plus button
  }
}

import UIKit

final class BaseNavigationController: UINavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
    
    // Customize the navigation bar appearance
    navigationBar.barTintColor = .red
    navigationBar.tintColor = .themeColor
    navigationBar.titleTextAttributes = [.foregroundColor: UIColor.red]
    
    // Set the appearance of the navigation bar when it is scrolled to the top
//      let scrollEdgeAppearance = UINavigationBarAppearance()
//      scrollEdgeAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//      scrollEdgeAppearance.backgroundColor = UIColor.blue
//      navigationBar.scrollEdgeAppearance = scrollEdgeAppearance

    if #available(iOS 13.0, *) {
      let navBarAppearance = UINavigationBarAppearance()
      navBarAppearance.largeTitleTextAttributes = [
        .foregroundColor: UIColor.themeColor,
        .font: UIFont.systemFont(ofSize: 24, weight: .semibold)
      ]
      navBarAppearance.titleTextAttributes = [
        .foregroundColor: UIColor.themeColor,
        .font: UIFont.systemFont(ofSize: 18, weight: .regular)
      ]
      navigationBar.standardAppearance = navBarAppearance
      navigationBar.scrollEdgeAppearance = navBarAppearance
    } else {
      navigationBar.largeTitleTextAttributes = [
        .foregroundColor: UIColor.red,
        .font: UIFont.systemFont(ofSize: 24.0)
      ]
      navigationBar.titleTextAttributes = [
        .foregroundColor: UIColor.themeColor,
        .font: UIFont.systemFont(ofSize: 18, weight: .regular)
      ]
    }
    
    // Hide the back button title
    let appearance = UIBarButtonItem.appearance()
    appearance.setTitleTextAttributes([.foregroundColor: UIColor.themeColor], for: .normal)
    appearance.setTitleTextAttributes([.foregroundColor: UIColor.themeColor.withAlphaComponent(0.5)], for: .highlighted)
    
    // Customize the cancel button's appearance
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
    
    //
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationController.self]).setTitleTextAttributes([.foregroundColor: UIColor.themeColor], for: .normal)
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).setTitleTextAttributes([.foregroundColor: UIColor.themeColor], for: .normal)
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes([.foregroundColor: UIColor.themeColor], for: .normal)
    
    UIButton.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = UIColor.themeColor
    UIButton.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor.themeColor
    UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.themeColor
    //
    
    // Set the background color for all toolbars
//    UIToolbar.appearance().backgroundColor = .red

    // Set the tint color for all toolbar items
    UIToolbar.appearance().tintColor = .themeColor
    
    tabBarController?.delegate = self
  }
  
  override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    // Check if the view controller being pushed is a subclass of BaseViewController
    if let baseViewController = viewController as? DocumentsViewController {
      // Set the hidesBottomBarWhenPushed property based on the value of showTabBar property
      baseViewController.hidesBottomBarWhenPushed = false//!baseViewController.navigationController?.toolbar.isHidden
    } else if let preview = viewController as? DocumentPreviewViewController {
      preview.hidesBottomBarWhenPushed = true
    }
    
    // Call the super method to push the view controller onto the stack
    super.pushViewController(viewController, animated: animated)
  }
}

extension BaseNavigationController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
      // Check if the selected view controller is the one you are interested in
//      if tabBarController.selectedItem == tabBarController.tabBar.items?[2] {
//          // Do something specific to that tab bar item
//          print("Tab bar item 2 was pressed")
//      }
    
    print(viewController.classForCoder)
  }
}

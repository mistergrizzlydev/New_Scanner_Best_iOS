//
//  MainCoordinator.swift
//  Project
//
//  Created by Mister Grizzly on 07.04.2023.
//

import UIKit

protocol Coordinator {
  var childCoordinators: [Coordinator] { get set }
  var navigationController: UINavigationController { get set }
  
  func start()
  
  func navigateToOnboarding()
  func navigateToDocuments(folder: Folder)
}

final class MainCoordinator: NSObject, Coordinator {
  var navigationController: UINavigationController
  
  var window: UIWindow?
  var childCoordinators = [Coordinator]()
  
  init(window: UIWindow?, navigationController: UINavigationController) {
    self.window = window
    self.navigationController = navigationController
    super.init()
  }
  
  func start() {
    let controller = SplashBuilder().buildViewController()!
    window?.rootViewController = controller
    window?.makeKeyAndVisible()
  }
  
  func navigateToProfile() {
    //        let profileVC = ProfileViewController()
    //        let navigationController = UINavigationController(rootViewController: profileVC)
    //        window?.rootViewController?.present(navigationController, animated: true, completion: nil)
  }
  
  func navigateToSettings() {
    //        let settingsVC = SettingsViewController()
    //        let navigationController = UINavigationController(rootViewController: settingsVC)
    //        window?.rootViewController?.present(navigationController, animated: true, completion: nil)
  }

  func navigateToOnboarding() {
    let controller = OnboardingBuilder().buildViewController()!
    controller.modalPresentationStyle = .fullScreen
    window?.rootViewController?.present(controller, animated: true)
  }
  
  func navigateToDocuments(folder: Folder) {
    /*
    let documents = DocumentsBuilder().buildViewController(folder: folder)!.wrappedInNavigation(title: "My Scans", image: .systemFolder(), tabBarItemName: "My Scans", tag: 0)
    let settings = SettingsBuilder().buildViewController()!.wrappedInNavigation(title: "Settings", image: .systemSettings(), tabBarItemName: "Settings", tag: 1)
    let tabBar = TabBarBuilder().buildViewController(with: [documents, settings])!
    tabBar.modalPresentationStyle = .fullScreen
    window?.rootViewController?.present(tabBar, animated: false)
     */

    let documents = DocumentsBuilder().buildViewController(folder: folder)!.wrappedInNavigation(title: "My Scans", image: .systemFolder(), tabBarItemName: "My Scans", tag: 0)
    //VisionBuilder().buildViewController()!.wrappedInNavigation(title: "All", image: .systemFolderFull(), tabBarItemName: "My Scans", tag: 0)
//    let documents = DemoVCBuilder().buildViewController()!.wrappedInNavigation(title: "Demo", image: .systemFolder(), tabBarItemName: "My Scans", tag: 0)
    let starred = StarredBuilder().buildViewController()!.wrappedInNavigation(title: "Starred Documents", image: .systemStar(), tabBarItemName: "Starred", tag: 1)
    let settings = SettingsBuilder().buildViewController()!.wrappedInNavigation(title: "Settings", image: .systemSettings(), tabBarItemName: "Settings", tag: 2)
    let tabBar = TabBarBuilder().buildViewController(with: [documents, starred, settings])!
    tabBar.modalPresentationStyle = .fullScreen
    window?.rootViewController?.present(tabBar, animated: false)
  }
}

/*
 final class MainCoordinator: Coordinator {
     var childCoordinators: [Coordinator] = []
     var navigationController: UINavigationController
     var window: UIWindow?

     init(navigationController: UINavigationController, window: UIWindow?) {
         self.navigationController = navigationController
         self.window = window
     }

     func start() {
         let viewController = SplashBuilder().buildViewController()
         navigationController.pushViewController(viewController!, animated: false)
     }

     func navigateToOnboarding() {
         let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
         onboardingCoordinator.delegate = self
         childCoordinators.append(onboardingCoordinator)
         onboardingCoordinator.start()
     }
 }

 extension MainCoordinator: OnboardingCoordinatorDelegate {
     func onboardingCoordinatorDidFinish(onboardingCoordinator: OnboardingCoordinator) {
         childCoordinators = childCoordinators.filter { $0 !== onboardingCoordinator }
     }
 }

 */

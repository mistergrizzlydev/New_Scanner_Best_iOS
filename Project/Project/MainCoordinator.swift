import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import QuickLook
import VisionKit
import Photos
import PhotosUI

protocol Coordinator {
  var childCoordinators: [Coordinator] { get set }
  var navigationController: UINavigationController { get set }
  
  func start()
  
  func navigateToOnboarding()
  func navigateToDocuments(from controller: UIViewController?, type: DocumentsType, folder: Folder)
  func navigateToDocumentPreview(from navigation: UINavigationController?, file: File)
  
  func navigateToAnnotation(navigation: UINavigationController?, file: File, delegate: QLPreviewControllerDelegate?)
  func navigateToAnnotation(controller: UIViewController?, file: File, delegate: QLPreviewControllerDelegate?)
  
  func presentShare(controller: UIViewController?, items: [Any], barButtonItem: UIBarButtonItem?, sourceView: UIView?)
  
  func presentDocumentPickerViewController(controller: UIViewController?, delegate: UIDocumentPickerDelegate?, allowsMultipleSelection: Bool)
  
  func presentPrint(with printingItem: Any?, jobName: String, showsNumberOfCopies: Bool, showsPaperOrientation: Bool)
  
  func presentDocumentScanner(in controller: UIViewController?, animated: Bool, delegate: VNDocumentCameraViewControllerDelegate?, completion: ((Bool) -> Void)?)
  func presentImagePicker(in controller: UIViewController?, delegate: PhotosUI.PHPickerViewControllerDelegate?, completion: ((Bool) -> Void)?)
}

extension Coordinator {
  func navigateToDocuments(from controller: UIViewController? = nil, type: DocumentsType = .myScans, folder: Folder) {
    navigateToDocuments(from: controller, type: type, folder: folder)
  }
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
//    let controller = OnboardingBuilder().buildViewController()!
//    controller.modalPresentationStyle = .fullScreen
//    window?.rootViewController?.dismiss(animated: true, completion: { [weak self] in
//      self?.window?.rootViewController = controller
//      self?.window?.makeKeyAndVisible()
//    })//?.present(controller, animated: true)

    let controller = StoryCollectionViewController(isFirstLaunch: true, fromSettings: false)
    controller.modalPresentationStyle = .fullScreen
    window?.rootViewController?.dismiss(animated: true, completion: { [weak self] in
      self?.window?.rootViewController = controller
      self?.window?.makeKeyAndVisible()
    })//?.present(controller, animated: true)
  }
  
  func navigateToDocuments(from controller: UIViewController? = nil, type: DocumentsType = .myScans, folder: Folder) {
    let documents = DocumentsBuilder().buildViewController(folder: folder, type: .myScans)!.wrappedInNavigation(title: DocumentsType.myScans.title,
                                                                                                                image: DocumentsType.myScans.image,
                                                                                                                tabBarItemName: DocumentsType.myScans.tabBarItemName, tag: 0)
    let starred = DocumentsBuilder().buildViewController(folder: folder, type: .starred)!.wrappedInNavigation(title: DocumentsType.starred.title,
                                                                                                              image: DocumentsType.starred.image,
                                                                                                              tabBarItemName: DocumentsType.starred.tabBarItemName, tag: 1)
    if let controller = controller {
      let image = type == .myScans ? UIImage.systemFolder() : .systemStar()
      let documents = DocumentsBuilder().buildViewController(folder: folder, type: type)!.wrappedInNavigation(title: type.title,
                                                                                                              image: type.image,
                                                                                                              tabBarItemName: type.tabBarItemName, tag: 0)
      controller.navigationController?.pushViewController(documents, animated: true)
    } else {
      let settings = SettingsBuilder().buildDefaultViewController()!.wrappedInNavigation(title: "Settings",
                                                                                         image: .systemSettings(),
                                                                                         tabBarItemName: "Settings", tag: 2)
      let tabBar = TabBarBuilder().buildViewController(with: [documents, starred, settings])!
      tabBar.modalPresentationStyle = .fullScreen
      window?.rootViewController?.present(tabBar, animated: false)
    }
  }
  
  func navigateToDocumentPreview(from navigation: UINavigationController?, file: File) {
    let controller = DocumentPreviewBuilder().buildViewController(file: file)!
    navigation?.pushViewController(controller, animated: true)
  }
  
  func navigateToAnnotation(navigation: UINavigationController?, file: File, delegate: QLPreviewControllerDelegate?) {
    let annotate = AnnotateBuilder().buildViewController(file: file)!
    //    annotate.delegate = delegate
    navigation?.pushViewController(annotate, animated: true)
  }
  
  func navigateToAnnotation(controller: UIViewController?, file: File, delegate: QLPreviewControllerDelegate?) {
    let annotate = AnnotateBuilder().buildViewController(file: file)!
    //    annotate.delegate = delegate
    controller?.present(annotate, animated: true)
  }
  
  func presentShare(controller: UIViewController?, items: [Any], barButtonItem: UIBarButtonItem?, sourceView: UIView?) {
    controller?.share(items, barButtonItem: barButtonItem, sourceView: sourceView)
  }
  
  func presentDocumentPickerViewController(controller: UIViewController?, delegate: UIDocumentPickerDelegate?, allowsMultipleSelection: Bool = true) {
    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
    
    //    if #available(iOS 11.0, *) {
    //      UINavigationBar.appearance(whenContainedInInstancesOf: [UIDocumentPickerViewController.self]).tintColor = .white
    //      UINavigationBar.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).tintColor = .white
    //      UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
    //    }
    
    documentPicker.allowsMultipleSelection = allowsMultipleSelection
    documentPicker.delegate = delegate
    documentPicker.modalPresentationStyle = .fullScreen
    controller?.present(documentPicker, animated: true, completion: {
      documentPicker.view.tintColor = .themeColor
    })
  }
  
  func presentPrint(with printingItem: Any?, jobName: String, showsNumberOfCopies: Bool, showsPaperOrientation: Bool) {
    let printController = UIPrintInteractionController.shared
    let printInfo = UIPrintInfo.printInfo()
    printInfo.outputType = .general
    printInfo.jobName = jobName
    printController.printInfo = printInfo
    printController.printingItem = printingItem
    printController.showsNumberOfCopies = showsNumberOfCopies
    printController.showsPaperOrientation = showsPaperOrientation
    printController.present(animated: true)
  }
  
  func presentDocumentScanner(in controller: UIViewController?, animated: Bool = true, delegate: VNDocumentCameraViewControllerDelegate? = nil, completion: ((Bool) -> Void)? = nil) {
    guard VNDocumentCameraViewController.isSupported else {
      // Document scanning is not supported on this device
      completion?(false)
      return
    }
    
    let documentScannerViewController = DocumentScannerController()
    documentScannerViewController.delegate = delegate
    controller?.present(documentScannerViewController, animated: animated, completion: {
      documentScannerViewController.pressButtons()
      documentScannerViewController.addHintView()
      documentScannerViewController.showLabels()
      
      documentScannerViewController.view.tintColor = .themeColor
      
      completion?(true)
    })
  }
  
  func presentImagePicker(in controller: UIViewController?, delegate: PhotosUI.PHPickerViewControllerDelegate? = nil, completion: ((Bool) -> Void)? = nil) {
    PHPhotoLibrary.checkAuthorizationStatus { status in
      switch status {
      case .authorized, .limited:
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images])
        //        configuration.preferredAssetRepresentationMode = .current
        configuration.selectionLimit = 10 // Set to 0 for no limit
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = delegate
        
        controller?.present(picker, animated: true, completion: {
          picker.view.tintColor = .themeColor
          completion?(true)
        })
      case .notDetermined, .restricted, .denied:
        completion?(false)
        return
      }
    }
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

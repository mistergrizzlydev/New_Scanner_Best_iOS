import UIKit
import Drops

extension UIViewController {
  func showDrop(message: String, icon: UIImage? = nil, duration: TimeInterval = 3.0) {
    let action = Drop.Action(icon: icon) {
      debugPrint("Drop tapped")
      Drops.hideCurrent()
    }
    let drop = Drop(title: message, action: action, position: .top, duration: 1.3)
  
    Drops.show(drop)
  }
  
  func hideDrops() {
    Drops.hideCurrent()
  }
}

extension UIViewController {
  func share(_ items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil,
             barButtonItem: UIBarButtonItem? = nil,
             sourceView: UIView? = nil,
             sourceRect: CGRect? = nil) {
    let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
    
    // Set excluded activity types if specified
    if let excludedActivityTypes = excludedActivityTypes {
      activityVC.excludedActivityTypes = excludedActivityTypes
    }
    
    // Set popover presentation controller properties for iPad
    if UIDevice.current.userInterfaceIdiom == .pad {
      activityVC.popoverPresentationController?.sourceView = sourceView ?? self.view
      activityVC.popoverPresentationController?.sourceRect = sourceRect ?? self.view.bounds
      activityVC.popoverPresentationController?.barButtonItem = barButtonItem
    }
    
    if let popoverController = activityVC.popoverPresentationController {
      popoverController.sourceView = sourceView // Set the source view for iPad
      popoverController.barButtonItem = barButtonItem // Set the source view for iPad
    }
    
    present(activityVC, animated: true)
  }
}

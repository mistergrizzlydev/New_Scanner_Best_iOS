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
  func share(_ items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
    let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
    
    // Set excluded activity types if specified
    if let excludedActivityTypes = excludedActivityTypes {
      activityVC.excludedActivityTypes = excludedActivityTypes
    }
    
    // Set popover presentation controller properties for iPad
    if UIDevice.current.userInterfaceIdiom == .pad {
      activityVC.popoverPresentationController?.sourceView = self.view
      activityVC.popoverPresentationController?.sourceRect = self.view.bounds
      activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
    }
    
    present(activityVC, animated: true)
  }
}

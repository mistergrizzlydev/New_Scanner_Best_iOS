import UIKit

protocol SplashViewControllerProtocol: AnyObject { }

final class SplashViewController: UIViewController, SplashViewControllerProtocol {
  var presenter: SplashPresenterProtocol!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
  }
}

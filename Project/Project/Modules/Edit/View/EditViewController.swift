import UIKit

protocol EditViewControllerProtocol: AnyObject {
  func prepare(with viewModel: EditViewModel)
}

class EditViewController: UIViewController, EditViewControllerProtocol {
  var presenter: EditPresenterProtocol!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }

  private func setupViews() {
    // Setup views
    
    let scannerViewController = ImageScannerController(image: UIImage(named: "testImage"), delegate: self)
//    scannerViewController.modalPresentationStyle = .fullScreen
    
//    if #available(iOS 13.0, *) {
//      scannerViewController.navigationBar.tintColor = .white
//    } else {
//      scannerViewController.navigationBar.tintColor = .white
//    }
//
//    present(scannerViewController, animated: true)
    
    // 2. Add the child view controller to the parent view controller
    addChild(scannerViewController)

    // 3. Add the child view controller's view as a subview of the parent view controller's view
    view.addSubview(scannerViewController.view)

    // 4. Notify the child view controller that it has been added to the parent view controller
    scannerViewController.didMove(toParent: self)
  }

  func prepare(with viewModel: EditViewModel) {
    title = viewModel.title
  }
}

extension EditViewController: ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        assertionFailure("Error occurred: \(error)")
    }

    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        scanner.dismiss(animated: true, completion: nil)
      
    }

    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true, completion: nil)
      
    }

}

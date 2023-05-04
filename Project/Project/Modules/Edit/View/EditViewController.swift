import UIKit

protocol EditViewControllerProtocol: AnyObject {
  func prepare(with viewModel: EditViewModel)
}

final class EditViewController: UIViewController, EditViewControllerProtocol {
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
    addChild(scannerViewController)
    view.addSubview(scannerViewController.view)
    scannerViewController.didMove(toParent: self)
  }
  
  func prepare(with viewModel: EditViewModel) {
    title = viewModel.title
  }
}

extension EditViewController: ImageScannerControllerDelegate {
  func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
    showDrop(message: error.localizedDescription, icon: .systemAlert())
  }
  
  func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
    scanner.dismiss(animated: true, completion: nil)
    
  }
  
  func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
    scanner.dismiss(animated: true, completion: nil)
    
  }
}

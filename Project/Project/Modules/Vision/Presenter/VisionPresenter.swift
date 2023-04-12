import UIKit

protocol VisionPresenterProtocol {
  func present()
}

class VisionPresenter: VisionPresenterProtocol {
  private weak var view: (VisionViewControllerProtocol & UIViewController)!

  init(view: VisionViewControllerProtocol & UIViewController) {
    self.view = view
  }

  func present() {
    // Fetch data or smth else...
    
    let getDocumentsURL = LocalFileManagerDefault().getDocumentsURL()
    let url = getDocumentsURL.appendingPathComponent("Test/invoice.pdf")
    view.prepare(with: .init(url: url))
  }
}

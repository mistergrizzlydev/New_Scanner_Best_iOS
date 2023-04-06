import UIKit

protocol DocumentPreviewPresenterProtocol {
  func present()
}

class DocumentPreviewPresenter: DocumentPreviewPresenterProtocol {
  private weak var view: (DocumentPreviewViewControllerProtocol & UIViewController)!
  let file: File
  
  init(view: DocumentPreviewViewControllerProtocol & UIViewController, file: File) {
    self.view = view
    self.file = file
  }

  func present() {
    // Fetch data or smth else...
    view.prepare(with: .init(title: file.name, file: file))
  }
}

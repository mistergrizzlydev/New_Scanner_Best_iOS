import UIKit

protocol TextPresenterProtocol {
  func present()
}

class TextPresenter: TextPresenterProtocol {
  private weak var view: (TextViewControllerProtocol & UIViewController)!
  private let file: File
  
  init(view: TextViewControllerProtocol & UIViewController, file: File) {
    self.view = view
    self.file = file
  }

  func present() {
    view.prepare(with: .init(file: file))
  }
}

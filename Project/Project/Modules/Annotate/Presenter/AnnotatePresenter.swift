import UIKit

protocol AnnotatePresenterProtocol {
  func present()
}

final class AnnotatePresenter: AnnotatePresenterProtocol {
  private weak var view: (AnnotateViewControllerProtocol & UIViewController)!
  private let file: File
  
  init(view: AnnotateViewControllerProtocol & UIViewController, file: File) {
    self.view = view
    self.file = file
  }

  func present() {
    view.prepare(with: .init(item: .init(documentURL: file.url)))
  }
}

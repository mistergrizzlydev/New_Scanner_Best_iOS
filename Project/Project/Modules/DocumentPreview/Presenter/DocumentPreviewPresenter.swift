import UIKit

protocol DocumentPreviewPresenterProtocol {
  func present()
  func onSignatureTapped()
  func onShareTapped()
}

class DocumentPreviewPresenter: DocumentPreviewPresenterProtocol {
  private weak var view: (DocumentPreviewViewControllerProtocol & UIViewController)!
  let file: File
  let coordinator: Coordinator
  
  init(view: DocumentPreviewViewControllerProtocol & UIViewController,
       file: File, coordinator: Coordinator) {
    self.view = view
    self.file = file
    self.coordinator = coordinator
  }

  func present() {
    // Fetch data or smth else...
    view.prepare(with: .init(title: file.name, file: file))
  }
  
  func onSignatureTapped() {
    coordinator.navigateToAnnotation(controller: view, file: file)
  }
  
  func onShareTapped() {
    coordinator.presentShare(controller: view, items: [file.url])
  }
}

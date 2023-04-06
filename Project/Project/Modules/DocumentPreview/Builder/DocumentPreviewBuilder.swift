import UIKit
import Swinject

protocol DocumentPreviewBuilderProtocol {
  func buildViewController(file: File) -> DocumentPreviewViewController!
}

class DocumentPreviewBuilder: DocumentPreviewBuilderProtocol {
  let container = Container()

  func buildViewController(file: File) -> DocumentPreviewViewController! {
    container.register(DocumentPreviewViewController.self) { _ in
      DocumentPreviewBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(DocumentPreviewPresenter.self)
    }

    container.register(DocumentPreviewPresenter.self) { c in
      DocumentPreviewPresenter(view: c.resolve(DocumentPreviewViewController.self)!, file: file)
    }

    return container.resolve(DocumentPreviewViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> DocumentPreviewViewController {
    let identifier = String(describing: DocumentPreviewViewController.self)
    let storyboard = UIStoryboard(name: identifier, bundle: .main)
    return storyboard.instantiateViewController(withIdentifier: identifier) as! DocumentPreviewViewController
  }
}

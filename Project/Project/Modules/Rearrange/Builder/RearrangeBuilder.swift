import UIKit
import Swinject

protocol RearrangeBuilderProtocol {
  func buildViewController(with pdfDocument: PDFDoc) -> RearrangeViewController!
}

final class RearrangeBuilder: RearrangeBuilderProtocol {
  let container = Container()

  func buildViewController(with pdfDocument: PDFDoc) -> RearrangeViewController! {
    container.register(RearrangeViewController.self) { _ in
      RearrangeBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(RearrangePresenter.self)
    }

    container.register(RearrangePresenter.self) { c in
      RearrangePresenter(view: c.resolve(RearrangeViewController.self)!, pdfDocument: pdfDocument)
    }

    return container.resolve(RearrangeViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> RearrangeViewController {
//    let identifier = String(describing: RearrangeViewController.self)
//    let storyboard = UIStoryboard(name: identifier, bundle: .main)
//    return storyboard.instantiateViewController(withIdentifier: identifier) as! RearrangeViewController
    RearrangeViewController(collectionViewLayout: UICollectionViewFlowLayout())
  }
}

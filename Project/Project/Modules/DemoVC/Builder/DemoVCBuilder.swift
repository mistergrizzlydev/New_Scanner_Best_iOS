import UIKit
import Swinject

protocol DemoVCBuilderProtocol {
  func buildViewController() -> DemoVCViewController!
}

class DemoVCBuilder: DemoVCBuilderProtocol {
  let container = Container()

  func buildViewController() -> DemoVCViewController! {
    container.register(DemoVCViewController.self) { _ in
      DemoVCBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(DemoVCPresenter.self)
    }

    container.register(DemoVCPresenter.self) { c in
      DemoVCPresenter(view: c.resolve(DemoVCViewController.self)!)
    }

    return container.resolve(DemoVCViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> DemoVCViewController {
    let identifier = String(describing: DemoVCViewController.self)
    let storyboard = UIStoryboard(name: identifier, bundle: .main)
    return storyboard.instantiateViewController(withIdentifier: identifier) as! DemoVCViewController
  }
}

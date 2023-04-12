import UIKit
import Swinject

protocol VisionBuilderProtocol {
  func buildViewController() -> VisionViewController!
}

class VisionBuilder: VisionBuilderProtocol {
  let container = Container()

  func buildViewController() -> VisionViewController! {
    container.register(VisionViewController.self) { _ in
      VisionBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(VisionPresenter.self)
    }

    container.register(VisionPresenter.self) { c in
      VisionPresenter(view: c.resolve(VisionViewController.self)!)
    }

    return container.resolve(VisionViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> VisionViewController {
    let identifier = String(describing: VisionViewController.self)
    let storyboard = UIStoryboard(name: identifier, bundle: .main)
    return storyboard.instantiateViewController(withIdentifier: identifier) as! VisionViewController
  }
}

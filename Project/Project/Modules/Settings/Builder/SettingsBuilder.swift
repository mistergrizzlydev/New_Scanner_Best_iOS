import UIKit
import Swinject

protocol SettingsBuilderProtocol {
  func buildViewController() -> SettingsViewController!
}

class SettingsBuilder: SettingsBuilderProtocol {
  let container = Container()

  func buildViewController() -> SettingsViewController! {
    container.register(SettingsViewController.self) { _ in
      SettingsBuilder.instantiateViewController()

    }.initCompleted { r, h in
      h.presenter = r.resolve(SettingsPresenter.self)
    }

    container.register(SettingsPresenter.self) { c in
      SettingsPresenter(view: c.resolve(SettingsViewController.self)!)
    }

    return container.resolve(SettingsViewController.self)!
  }

  deinit {
    container.removeAll()
  }

  private static func instantiateViewController() -> SettingsViewController {
    let identifier = String(describing: SettingsViewController.self)
    let storyboard = UIStoryboard(name: identifier, bundle: .main)
    return storyboard.instantiateViewController(withIdentifier: identifier) as! SettingsViewController
  }
}

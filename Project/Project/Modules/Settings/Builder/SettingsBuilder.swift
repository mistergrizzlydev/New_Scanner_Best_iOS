import UIKit
import Swinject

//enum SettingsType {
//    case `default`
//    case scanning
//}

protocol SettingsBuilderProtocol {
    func buildDefaultViewController() -> SettingsViewController!
    func buildScannerViewController() -> ScanningSettingsViewController!
}

class SettingsBuilder: SettingsBuilderProtocol {
    let container = Container()
    
    func buildDefaultViewController() -> SettingsViewController! {
        container.register(SettingsViewController.self) { _ in
            SettingsBuilder.instantiateDefaultViewController()
            
        }.initCompleted { r, h in
            h.presenter = r.resolve(SettingsPresenter.self)
        }
        
        container.register(SettingsPresenter.self) { c in
            SettingsPresenter(view: c.resolve(SettingsViewController.self)!)
        }
        
        return container.resolve(SettingsViewController.self)!
    }
    
    func buildScannerViewController() -> ScanningSettingsViewController! {
        container.register(ScanningSettingsViewController.self) { _ in
            SettingsBuilder.instantiateScannerViewController()
            
        }.initCompleted { r, h in
            h.presenter = r.resolve(SettingsPresenter.self)
        }
        
        container.register(SettingsPresenter.self) { c in
            SettingsPresenter(view: c.resolve(ScanningSettingsViewController.self)!)
        }
        
        return container.resolve(ScanningSettingsViewController.self)!
    }
    
    deinit {
        container.removeAll()
    }
    
    private static func instantiateDefaultViewController() -> SettingsViewController {
        SettingsViewController()
    }
    
    private static func instantiateScannerViewController() -> ScanningSettingsViewController {
        ScanningSettingsViewController()
    }
}

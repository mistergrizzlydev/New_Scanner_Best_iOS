import UIKit
import Swinject

protocol AnnotateBuilderProtocol {
  func buildViewController(file: File) -> AnnotateViewController!
}

final class AnnotateBuilder: AnnotateBuilderProtocol {
  let container = Container()
  
  func buildViewController(file: File) -> AnnotateViewController! {
    container.register(AnnotateViewController.self) { _ in
      AnnotateBuilder.instantiateViewController()
      
    }.initCompleted { r, h in
      h.presenter = r.resolve(AnnotatePresenter.self)
    }
    
    container.register(AnnotatePresenter.self) { c in
      AnnotatePresenter(view: c.resolve(AnnotateViewController.self)!, file: file)
    }
    
    return container.resolve(AnnotateViewController.self)!
  }
  
  deinit {
    container.removeAll()
  }
  
  private static func instantiateViewController() -> AnnotateViewController {
    AnnotateViewController()
  }
}

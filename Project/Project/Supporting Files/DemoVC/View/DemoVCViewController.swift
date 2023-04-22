import UIKit

protocol DemoVCViewControllerProtocol: AnyObject {
  func prepare(with viewModel: DemoVCViewModel)
}

class DemoVCViewController: UIViewController, DemoVCViewControllerProtocol {
  var presenter: DemoVCPresenterProtocol!
  
  private enum SortType: Int {
    case date = 0
    case name
    case size
    
    var title: String {
      switch self {
      case .date:
        return "Date"
      case .name:
        return "Name"
      case .size:
        return "Size"
      }
    }
  }
  
  private var sortType: SortType? {
    didSet {
      if let menu = navigationItem.rightBarButtonItem?.menu {
        navigationItem.rightBarButtonItem?.menu = updateActionState(actionTitle: sortType?.title ?? "", menu: menu)
      }
    }
  }

  lazy var dateAction = UIAction(title: SortType.date.title, handler: { _ in
    self.sortType = .date
  })
  lazy var nameAction = UIAction(title: SortType.name.title, handler: { _ in
    self.sortType = .name
  })
  lazy var sizeAction = UIAction(title: SortType.size.title, handler: { _ in
    self.sortType = .size
  })
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
    
    
    let button = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: nil)
    // add the actions to the button's menu
    button.menu = UIMenu(title: "", children: [dateAction, nameAction, sizeAction])
    navigationItem.rightBarButtonItem = button
    
    // set the initial sort type
    sortType = .date
  }
  
//  private func updateActionState(actionTitle: String? = nil, menu: UIMenu) -> UIMenu {
//    if let actionTitle = actionTitle {
//      menu.children.forEach { action in
//        guard let childMenu = action as? UIMenu else {
//          return
//        }
//
//        childMenu.children.forEach { action in
//          guard let action = action as? UIAction else {
//            return
//          }
//          action.state = action.title == actionTitle ? .on : .off
//        }
//      }
//    } else {
//      let action = menu.children.first as? UIAction
//      action?.state = .on
//    }
//    return menu
//  }
  
  private func updateActionState(actionTitle: String? = nil, menu: UIMenu) -> UIMenu {
    if let actionTitle = actionTitle {
      menu.children.forEach { action in
        guard let action = action as? UIAction else {
          return
        }
        action.state = action.title == actionTitle ? .on : .off
      }
    } else {
      let action = menu.children.first as? UIAction
      action?.state = .on
    }
    return menu
  }
  
  private func setupViews() {
    // Setup views
  }
  
  func prepare(with viewModel: DemoVCViewModel) {
    title = viewModel.title
  }
}

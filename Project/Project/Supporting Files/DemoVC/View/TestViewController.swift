import UIKit

final class TestViewController: UIViewController {
  private enum SortType: String {
    case date = "Date"
    case name = "Name"
    case size = "Size"
    
    static var allCases: [SortType] {
      [.date, .name, .size]
    }
  }
  
  private var sortedFilesType: SortType = .date {
    didSet {
      if let menu = navigationItem.rightBarButtonItem?.menu {
        navigationItem.rightBarButtonItem?.menu = updateActionState(actionTitle: sortedFilesType.rawValue, menu: menu)
      }
    }
  }
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMenu()
  }
  
  private func setupMenu() {
    let section2Actions = SortType.allCases.compactMap { UIAction(title: $0.rawValue) { [weak self] action in
        let sortFileType = SortType(rawValue: action.title) ?? .date
        self?.sortedFilesType = sortFileType
      }
    }
    
    let button = UIBarButtonItem(title: "Sort by:", style: .plain, target: self, action: nil)
    button.menu = UIMenu(title: "", children: section2Actions)
    navigationItem.rightBarButtonItem = button
  }
}

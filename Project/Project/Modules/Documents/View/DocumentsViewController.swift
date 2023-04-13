import UIKit

protocol DocumentsViewControllerProtocol: AnyObject {
  func prepare(with viewModels: [DocumentsViewModel], title: String)
}

final class DocumentsViewController: UITableViewController, DocumentsViewControllerProtocol {
  private struct Constants {
    static let title = "My Scans"
  }
  
  var presenter: DocumentsPresenterProtocol!
  private var viewModels: [DocumentsViewModel] = []
  private var isAllSelected = false
  
  private var menuButton: UIBarButtonItem?
  
  private var sortedFilesType: SortType = .date {
    didSet {
      if let menu = menuButton?.menu {
        menuButton?.menu = UIMenu.updateActionState(actionTitle: sortedFilesType.rawValue, menu: menu)
      }
    }
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
    navigationController?.showHideFloatingButton(editing, animated: animated)
//    tabBarController?.showHideTabBar(editing, animated: animated)

    navigationController?.setToolbarHidden(!editing, animated: animated)
    navigationItem.searchController?.searchBar.isUserInteractionEnabled = !editing
    navigationItem.rightBarButtonItems?.first(where: { $0.accessibilityIdentifier == "menuButton" })?.isEnabled = !editing
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }
  
  private func setupViews() {
    tableView.estimatedRowHeight = UITableView.automaticDimension
    setupSearchBar()
    
    tableView.allowsMultipleSelectionDuringEditing = true
    tableView.allowsSelectionDuringEditing = true
    
    menuButton = UIBarButtonItem(image: .systemEllipsisCircle(), style: .plain, target: self, action: nil)
    menuButton?.accessibilityIdentifier = "menuButton"
    sortedFilesType = presenter.sortedFilesType
    
    let menuItem1 = UIAction(title: "New Folder", image: .systemAddFolder()) { [weak self] action in
      guard let self = self else { return }
      self.presentAlertWithTextField(title: "Aaa", message: "bbb", placeholder: "placeholder") { text in
        print(text)
      }
    }
    
    let section2Actions = SortType.allCases.compactMap { UIAction(title: $0.rawValue, image: $0.image) { [weak self] action in
      let sortFileType = SortType(rawValue: action.title) ?? .date
      self?.sortedFilesType = sortFileType
      self?.presenter.on(sortBy: sortFileType)
    }
    }
    let section1 = UIMenu(title: "Create a new folder", options: .displayInline, children: [menuItem1])
    let section2 = UIMenu(title: "Sort by:", options: .displayInline, children: section2Actions)
    let menu = UIMenu(options: .displayInline, children: [section1, section2])
    menuButton?.menu = UIMenu.updateActionState(actionTitle: sortedFilesType.rawValue, menu: menu)
    navigationItem.setRightBarButtonItems([menuButton!, editButtonItem], animated: true)
    
    //    hidesBottomBarWhenPushed = true
    
    let toolbarItems = FileManagerToolbarAction.toolbarItems(target: self, action: #selector(toolbarButtonTapped(_:)))
    self.toolbarItems = toolbarItems
  }
  
  @objc private func toolbarButtonTapped(_ sender: UIBarButtonItem) {
    guard let action = FileManagerToolbarAction(rawValue: sender.tag) else {
      return
    }
    
    switch action {
    case .share:
      // handle share action
      print("share")
    case .merge:
      // handle merge action
      print("merge")
    case .move:
      // handle move action
      print("move")
    case .delete:
      // handle delete action
      print("delete")
    }
  }

  @objc private func selectAllButtonTapped() {
    isAllSelected.toggle()
    
    if isAllSelected {
      for sectionIndex in 0..<tableView.numberOfSections {
        for rowIndex in 0..<tableView.numberOfRows(inSection: sectionIndex) {
          let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
          tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
      }
      navigationItem.leftBarButtonItem?.title = "Deselect All"
    } else {
      for indexPath in tableView.indexPathsForSelectedRows ?? [] {
        tableView.deselectRow(at: indexPath, animated: false)
      }
      navigationItem.leftBarButtonItem?.title = "Select All"
    }
  }
  
  private func setupSearchBar() {
    // Create the search controller
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search"
    searchController.searchBar.scopeButtonTitles = ["All", "Folders", "Files"]
    searchController.searchBar.showsScopeBar = false
    searchController.searchBar.delegate = self
    
    // Add the search controller to the navigation item
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
    navigationItem.hidesSearchBarWhenScrolling = false
    
    // Customize the search bar's appearance
    //    searchController.searchBar.backgroundColor = .red
    searchController.searchBar.tintColor = .black
    searchController.searchBar.barTintColor = .black
    searchController.searchBar.isTranslucent = false
    searchController.searchBar.searchTextField.textColor = .black
  }
  
  func prepare(with viewModels: [DocumentsViewModel], title: String) {
    self.viewModels = viewModels
    navigationItem.title = title
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.reloadData()
  }
}

extension DocumentsViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModels.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: DocumentsTableViewCell.reuseIdentifier,
                                                   for: indexPath) as? DocumentsTableViewCell else {
      return UITableViewCell()
    }
    let viewModel = viewModels[indexPath.row]
    cell.configure(with: viewModel)
    return cell
  }
}

extension DocumentsViewController {
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard !tableView.isEditing else { return }
    tableView.deselectRow(at: indexPath, animated: true)
    presenter.didSelect(at: indexPath, viewModel: viewModels[indexPath.row])
  }
}

extension DocumentsViewController {
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .none // Disable swipe-to-delete while editing
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return tableView.isEditing
  }
}

extension DocumentsViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    // Handle search results here
  }
}

extension DocumentsViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    // Show the scope bar when the user enters some text
    searchBar.showsScopeBar = !searchText.isEmpty
    
    navigationController?.navigationBar.sizeToFit()
    navigationItem.largeTitleDisplayMode = .always
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    // Hide the scope bar when the search bar is dismissed
    searchBar.showsScopeBar = false
  }
}

extension DocumentsViewController: UIContextMenuInteractionDelegate {
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let interaction = UIContextMenuInteraction(delegate: self)
    cell.addInteraction(interaction)
  }
  
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    guard !tableView.isEditing, let indexPath = tableView.indexPathForRow(at: location) else { return nil }
    
    let item = viewModels[indexPath.row]
    
    let actions = FileManagerAction.allCases.sorted(by: { $0.rawValue < $1.rawValue }).compactMap { createAction(from: $0) { action in
      switch action.title {
      case FileManagerAction.rename.title:
        // Handle rename action
        print("Rename action tapped")
      case FileManagerAction.move.title:
        // Handle move action
        print("Move action tapped")
      case FileManagerAction.copy.title:
        // Handle copy action
        print("Copy action tapped")
      case FileManagerAction.star.title:
        // Handle star action
        print("Star action tapped")
      case FileManagerAction.share.title:
        // Handle share action
        print("Share action tapped")
      case FileManagerAction.properties.title:
        // Handle properties action
        print("Properties action tapped")
      default:
        break
      }
    }}
    
    let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
      // Delete the item from your data model and update the table view
    }
    
    let deleteMenu = UIMenu(title: "", options: .displayInline, children: [deleteAction])
    let actionsMenu = UIMenu(title: "", options: .displayInline, children: actions)
    let menu = UIMenu(children: [actionsMenu, deleteMenu])
    return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in menu })
  }
  
  private func createAction(from managerAction: FileManagerAction, handler: @escaping UIActionHandler) -> UIAction {
    return UIAction(title: managerAction.title, image: UIImage(systemName: managerAction.iconName), handler: handler)
  }
}

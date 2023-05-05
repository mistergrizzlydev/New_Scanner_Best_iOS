import UIKit

protocol DocumentsViewControllerProtocol: AnyObject {
  func prepare(with viewModels: [DocumentsViewModel], title: String)
  func updateEditButtonItemEnabled()
  
  func display(toolbarButtonAction type: FileManagerToolbarAction, isEnabled: Bool)
  func endEditing()
}

final class DocumentsViewController: BaseFloatingTableViewController, DocumentsViewControllerProtocol {
  private struct Constants {
    
  }
  
  var presenter: DocumentsPresenterProtocol!
  private var viewModels: [DocumentsViewModel] = []
  private var filteredViewModels: [DocumentsViewModel] = []
  
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
    //    tabBarController?.showHideTabBar(editing, animated: animated)
    
    navigationController?.setToolbarHidden(!editing, animated: animated)
    navigationItem.searchController?.searchBar.isUserInteractionEnabled = !editing
    navigationItem.rightBarButtonItems?.first(where: { $0.accessibilityIdentifier == "menuButton" })?.isEnabled = !editing
    
    let mergeButton = toolbarItems?.first(where: { $0.tag == FileManagerToolbarAction.merge.rawValue })
    mergeButton?.isEnabled = !editing
    
    showHideFloatingStackView(isHidden: isEditing)
    display(toolbarButtonAction: .merge, isEnabled: !isEditing)
    display(toolbarButtonAction: .duplicate, isEnabled: !isEditing)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setupViews()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    presenter.present()
  }
  
  func endEditing() {
    if let button = navigationItem.rightBarButtonItems?.first(where: { $0.title?.lowercased() == "done" }){
      _ = button.target?.perform(button.action, with: button)
    }
    tableView.setEditing(false, animated: true)
  }
  
  private func setupViews() {
    tableView.estimatedRowHeight = UITableView.automaticDimension
    if #available(iOS 15.0, *) {
      tableView.sectionHeaderTopPadding = 0.0
    }
    
    setupSearchBar()
    
    tableView.allowsMultipleSelectionDuringEditing = true
    tableView.allowsSelectionDuringEditing = true
    
    menuButton = UIBarButtonItem(image: .systemEllipsisCircle(), style: .plain, target: self, action: nil)
    menuButton?.accessibilityIdentifier = "menuButton"
    sortedFilesType = presenter.sortedFilesType
    
    let menuItem1 = UIAction(title: "New Folder", image: .systemAddFolder()) { [weak self] action in
      guard let self = self else { return }
      self.presenter.createNewFolder()
    }
    
//    let galleryAction = UIAction(title: "Photo Library", image: UIImage(systemName: "photo.on.rectangle")) { [weak self] _ in
//      self?.presenter.presentCamera(animated: true)
//    }
    let documentsAction = UIAction(title: "Choose Files", image: UIImage(systemName: "folder")) { [weak self] _ in
      self?.presenter.onImportFileFromDocuments()
    }
    let importMenu = UIMenu(title: "Import Documents from:", options: .displayInline, children: [documentsAction])//, galleryAction])
    
    let section2Actions = SortType.allCases.compactMap { UIAction(title: $0.rawValue, image: $0.image) { [weak self] action in
      let sortFileType = SortType(rawValue: action.title) ?? .date
      self?.sortedFilesType = sortFileType
      self?.presenter.on(sortBy: sortFileType)
    }
    }
    let section1 = UIMenu(title: "Create a new folder", options: .displayInline, children: [menuItem1])
    let section2 = UIMenu(title: "Sort by:", options: .displayInline, children: section2Actions)
    let menu = UIMenu(options: .displayInline, children: [section1, importMenu, section2])
    menuButton?.menu = UIMenu.updateActionState(actionTitle: sortedFilesType.rawValue, menu: menu)
    navigationItem.setRightBarButtonItems([menuButton!, editButtonItem], animated: true)
    
    //    hidesBottomBarWhenPushed = true
    let toolbarItems = FileManagerToolbarAction.toolbarItems(target: self, action: #selector(toolbarButtonTapped(_:)))
    self.toolbarItems = toolbarItems
    
    cameraButtonTapped = { [weak self] in
      self?.presenter.presentCamera(animated: true)
    }
    
    galleryButtonTapped = { [weak self] in
      self?.presenter.presentPhotoLibrary()
    }
  }
  
  func updateEditButtonItemEnabled() {
    if viewModels.isEmpty {
      editButtonItem.isEnabled = false
    } else {
      editButtonItem.isEnabled = true
    }
  }
  
  @objc private func toolbarButtonTapped(_ sender: UIBarButtonItem) {
    let selectedViewModels = tableView.indexPathsForSelectedRows?.compactMap { viewModels[$0.row] }
    guard let action = FileManagerToolbarAction(rawValue: sender.tag), let selectedViewModels = selectedViewModels else { return }
    switch action {
    case .share:
      presenter.onShareTapped(selectedViewModels, item: getToolbarItem(type: .share), sourceView: nil)
    case .merge:
      presenter.merge(viewModels: selectedViewModels)
    case .duplicate:
      self.presenter.duplicate(for: selectedViewModels)
    case .move:
      self.presenter.presentMove(selectedViewModels: selectedViewModels, viewModels: viewModels)
    case .delete:
      presenter.onDeleteTapped(selectedViewModels)
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
  
  private var searchController: UISearchController?
  
  private func setupSearchBar() {
    // Set up the search controller
    searchController = UISearchController(searchResultsController: nil)
    searchController!.searchResultsUpdater = self
    searchController!.obscuresBackgroundDuringPresentation = false
    searchController!.searchBar.placeholder = "Search"
    
    // Set up the scopes
    searchController!.searchBar.scopeButtonTitles = SearchScope.allCases.compactMap { $0.rawValue }
    searchController!.searchBar.showsScopeBar = false
    searchController!.searchBar.delegate = self
    
    // Add the search controller to the navigation item
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
  }
  
  private var wasSearchBarCancelButtonClicked = false
  
  private func isFiltering() -> Bool {
    if wasSearchBarCancelButtonClicked {
      return false
    } else {
      guard let searchController = searchController else { return false }
      return searchController.isActive && !searchBarIsEmpty()
    }
  }
  
  private func searchBarIsEmpty() -> Bool {
    return searchController?.searchBar.text?.isEmpty ?? true
  }
  
  func prepare(with viewModels: [DocumentsViewModel], title: String) {
    self.viewModels = viewModels
    navigationItem.title = title
    
    setupViews()
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.reloadData()
  }
}

extension DocumentsViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    isFiltering() ? filteredViewModels.count : viewModels.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: DocumentsTableViewCell.reuseIdentifier,
                                                   for: indexPath) as? DocumentsTableViewCell else { return UITableViewCell() }
    let viewModel = isFiltering() ? filteredViewModels[indexPath.row] : viewModels[indexPath.row]
    cell.configure(with: viewModel)
    return cell
  }
}

extension DocumentsViewController {
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView.isEditing {
      let selectedViewModels = tableView.indexPathsForSelectedRows?.compactMap { isFiltering() ? filteredViewModels[$0.row] : viewModels[$0.row] }
      presenter.checkMergeButton(for: selectedViewModels)
    } else {
      tableView.deselectRow(at: indexPath, animated: true)
      presenter.didSelect(at: indexPath, viewModel: viewModels[indexPath.row])
    }
  }
  
  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    if tableView.isEditing {
      let selectedViewModels = tableView.indexPathsForSelectedRows?.compactMap { isFiltering() ? filteredViewModels[$0.row] : viewModels[$0.row] }
      presenter.checkMergeButton(for: selectedViewModels)
    }
  }
}

extension DocumentsViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    // Handle search results here
  }
}

extension DocumentsViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    wasSearchBarCancelButtonClicked = false
    // Show the scope bar when the user enters some text
    searchBar.showsScopeBar = !searchText.isEmpty
    
    navigationController?.navigationBar.sizeToFit()
    navigationItem.largeTitleDisplayMode = .always
    
    guard let text = searchBar.text else { return }
    if text.isEmpty {
      filteredViewModels = []
      tableView.reloadData()
    } else {
      filterContentForSearchText(text, scope: SearchScope(index: searchBar.selectedScopeButtonIndex))
    }
  }
  
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    guard let text = searchBar.text, !text.isEmpty else { return }
    filterContentForSearchText(text, scope: SearchScope(index: searchBar.selectedScopeButtonIndex))
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.showsScopeBar = false
    wasSearchBarCancelButtonClicked = true
    filteredViewModels = []
    tableView.reloadData()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    view.endEditing(true)
    tableView.reloadData()
    
    navigationController?.navigationBar.sizeToFit()
    navigationItem.largeTitleDisplayMode = .always
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    // Hide the scope bar when the search bar is dismissed
    searchBar.showsScopeBar = false
  }
  
  private func filterContentForSearchText(_ searchText: String, scope: SearchScope) {
    filteredViewModels = presenter.didSearch(for: searchText, in: scope)
    tableView.reloadData()
  }
}

extension DocumentsViewController: UIContextMenuInteractionDelegate {
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let interaction = UIContextMenuInteraction(delegate: self)
    cell.addInteraction(interaction)
    
    if let editControl = cell.editingAccessoryView as? UIControl,
       let editView = editControl.subviews.first {
      editView.backgroundColor = UIColor.red
    }
  }
  
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    guard !tableView.isEditing, let cell = interaction.view as? DocumentsTableViewCell, let indexPath = tableView.indexPath(for: cell) else { return nil }
    
    let viewModel = isFiltering() ? filteredViewModels[indexPath.row] : viewModels[indexPath.row]
    
    let actions = FileManagerAction.allCases(file: viewModel.file).compactMap { FileManagerAction.createAction(from: $0, viewModel: viewModel) { [weak self] action in
      switch action.title {
      case FileManagerAction.rename.title(file: viewModel.file):
        self?.presenter.onRenameTapped(viewModel)
      case FileManagerAction.move.title(file: viewModel.file):
        self?.presenter.presentMove(selectedViewModels: [viewModel], viewModels: self?.viewModels ?? [])
      case FileManagerAction.copy.title(file: viewModel.file):
        self?.presenter.onCopyTapped(viewModel)
      case FileManagerAction.star.title(file: viewModel.file):
        self?.presenter.onStarredTapped(viewModel)
      case FileManagerAction.share.title(file: viewModel.file):
        self?.presenter.onShareTapped([viewModel], item: nil, sourceView: cell)
      case FileManagerAction.properties.title(file: viewModel.file):
        self?.presenter.onDetailsTapped(viewModel)
      default:
        break
      }
    }}
    
    let deleteAction = FileManagerAction.createDeleteAction { [weak self] action in
      self?.presenter.onDeleteTapped([viewModel])
    }
    
    let deleteMenu = UIMenu(title: "", options: .displayInline, children: [deleteAction])
    let actionsMenu = UIMenu(title: "", options: .displayInline, children: actions)
    let menu = UIMenu(children: [actionsMenu, deleteMenu])
    return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in menu })
  }
}

extension DocumentsViewController {
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true //tableView.isEditing
  }
  
  override func tableView(_ tableView: UITableView,
                          editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .none
  }
  
  override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
    // Disable editing mode if the user is swiping to show swipe actions
    if tableView.panGestureRecognizer.translation(in: tableView.superview).x > 0 {
      tableView.setEditing(false, animated: true)
    }
  }
  
  override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
    super.tableView(tableView, didEndEditingRowAt: indexPath)
    
    // Re-enable the edit button when the swipe action is closed
    editButtonItem.isEnabled = true
  }
  
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    editButtonItem.isEnabled = false
    let viewModel = isFiltering() ? filteredViewModels[indexPath.row] : viewModels[indexPath.row]
    let unstarTitle = FileManagerAction.star.title(file: viewModel.file)
    let deleteTitle = FileManagerAction.delete.title(file: viewModel.file)
    
    let unstarAction = UIContextualAction(style: .normal, title: unstarTitle) { (action, view, completionHandler) in
      // Perform the unstar action for the file at the given indexPath
      self.presenter.onStarredTapped(viewModel)
      completionHandler(true)
    }
    unstarAction.image = UIImage(systemName: FileManagerAction.star.iconName(file: viewModel.file))
    unstarAction.backgroundColor = .systemGray
    
    let deleteAction = UIContextualAction(style: .destructive, title: deleteTitle) { (action, view, completionHandler) in
      // Perform the unstar action for the file at the given indexPath
      self.presenter.onDeleteTapped([viewModel])
      completionHandler(true)
    }
    deleteAction.image = UIImage(systemName: FileManagerAction.delete.iconName(file: viewModel.file))
    deleteAction.backgroundColor = .red
    
    let configuration = UISwipeActionsConfiguration(actions: [deleteAction, unstarAction])
    return configuration
  }
}

extension DocumentsViewController {
  func display(toolbarButtonAction type: FileManagerToolbarAction, isEnabled: Bool) {
    toolbarItems?.first(where: { $0.tag == type.rawValue })?.isEnabled = isEnabled
  }
  
  func getToolbarItem(type: FileManagerToolbarAction) -> UIBarButtonItem? {
    toolbarItems?.first(where: { $0.tag == type.rawValue })
  }
}

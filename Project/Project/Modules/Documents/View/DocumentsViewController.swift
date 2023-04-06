import UIKit

protocol DocumentsViewControllerProtocol: AnyObject {
  func prepare(with viewModels: [DocumentsViewModel])
}

final class DocumentsViewController: UITableViewController, DocumentsViewControllerProtocol {
  private struct Constants {
    static let title = "My Scans"
  }
  
  var presenter: DocumentsPresenterProtocol!
  private var viewModels: [DocumentsViewModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }
  
  private func setupViews() {
    navigationItem.title = Constants.title
    
    tableView.estimatedRowHeight = UITableView.automaticDimension
    
    setupSearchBar()
  }
  
  private func setupSearchBar() {
    //    // Create the search controller
    //    let searchController = UISearchController(searchResultsController: nil)
    //    searchController.searchResultsUpdater = self
    //    searchController.hidesNavigationBarDuringPresentation = false
    //    searchController.searchBar.placeholder = "Search"
    //
    //    // Add the search controller to the navigation item
    //    navigationItem.searchController = searchController
    //
    //    // Show the search bar by default
    //    navigationItem.hidesSearchBarWhenScrolling = false
    //
    //    // Ensure that the search bar is not obscured by the navigation bar
    //    navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
    //
    //    // Set the search bar's scope buttons (optional)
    //    searchController.searchBar.scopeButtonTitles = ["All", "Title", "Author"]
    //    searchController.searchBar.showsScopeBar = true
    
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
    
    // Customize the search bar's appearance
    //    searchController.searchBar.backgroundColor = .red
    searchController.searchBar.tintColor = .black
    searchController.searchBar.barTintColor = .black
    searchController.searchBar.isTranslucent = false
    searchController.searchBar.searchTextField.textColor = .black
    
    // Customize the cancel button's appearance
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
    
    // Enable large titles
    navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  func prepare(with viewModels: [DocumentsViewModel]) {
    self.viewModels = viewModels
    
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
    tableView.deselectRow(at: indexPath, animated: true)
    presenter.didSelect(at: indexPath, viewModel: viewModels[indexPath.row])
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

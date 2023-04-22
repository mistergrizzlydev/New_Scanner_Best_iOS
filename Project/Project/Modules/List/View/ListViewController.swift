import UIKit

protocol ListViewControllerProtocol: AnyObject {
  func prepare(with viewModels: [ListViewModel])
}

final class ListViewController: UITableViewController, ListViewControllerProtocol {
  var presenter: ListPresenterProtocol!
  private var viewModels: [ListViewModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }

  private func setupViews() {
    // Setup views
    navigationItem.title = "Move to:"
    tableView.estimatedRowHeight = 54.0
  }

  func prepare(with viewModels: [ListViewModel]) {
    self.viewModels = viewModels
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.reloadData()
  }
}

extension ListViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModels.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier,
                                                   for: indexPath) as? ListTableViewCell else { return UITableViewCell() }
    cell.configure(with: viewModels[indexPath.row])
    return cell
  }
}

extension ListViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

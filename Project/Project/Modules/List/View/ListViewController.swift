import UIKit

protocol ListViewControllerProtocol: AnyObject {
  func prepare(with viewModels: [ListViewModel])
}

final class ListViewController: UITableViewController, ListViewControllerProtocol {
  var presenter: ListPresenterProtocol!
  
  private var viewModels: [ListViewModel] = []
  private var selectedIndexPath: IndexPath?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    selectedIndexPath = nil
  }

  private func setupViews() {
    // Setup views
    navigationItem.title = "Move to:"
    tableView.estimatedRowHeight = 54.0
    
    let moveButton = UIBarButtonItem(title: "Move", style: .plain, target: self, action: #selector(onMoveTapped(_:)))
    navigationItem.rightBarButtonItem = moveButton
  }
  
  func prepare(with viewModels: [ListViewModel]) {
    self.viewModels = viewModels
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.reloadData()
  }
  
  @objc private func onMoveTapped(_ sender: UIButton) {
    presenter.move(at: selectedIndexPath)
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
    let url = viewModels[indexPath.row].file.url
    presenter.presentNext(from: url)
    selectedIndexPath = indexPath
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

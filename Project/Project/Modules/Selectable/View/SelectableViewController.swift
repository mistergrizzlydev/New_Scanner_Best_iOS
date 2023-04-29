import UIKit

protocol SelectableViewControllerProtocol: AnyObject {
  func prepare(with viewModel: SelectableViewModel)
}

final class SelectableViewController: UITableViewController, SelectableViewControllerProtocol {
  var presenter: SelectablePresenterProtocol!

  private var options: [String] = []
  private var selectedOption: String?
  
  init() {
    if #available(iOS 13.0, *) {
      super.init(style: .insetGrouped)
    } else {
      super.init(style: .grouped)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }

  private func setupViews() {
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
    tableView.tableFooterView = UIView()
  }

  func prepare(with viewModel: SelectableViewModel) {
    navigationItem.title = viewModel.title
    options = viewModel.options
    selectedOption = viewModel.selectedOption
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return options.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let selectedOption = selectedOption else { return UITableViewCell() }
    let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
    let option = options[indexPath.row]
    cell.textLabel?.text = option
    cell.accessoryType = option.lowercased() == selectedOption.lowercased() ? .checkmark : .none
    cell.tintColor = .themeColor
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedOption = options[indexPath.row]
    self.selectedOption = selectedOption
    tableView.reloadData()
    presenter.didSelect(at: indexPath, selectedOption: selectedOption)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    48.0
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    40
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    UIView()
  }
}

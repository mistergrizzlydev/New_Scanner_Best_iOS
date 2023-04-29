import UIKit
import QuickTableViewController
import Sandwich

protocol OCRLanguagesViewControllerProtocol: AnyObject {
  func prepare(with viewModel: OCRLanguagesViewModel)
}

final class OCRLanguagesViewController: QuickTableViewController, OCRLanguagesViewControllerProtocol {
  var presenter: OCRLanguagesPresenterProtocol!
  private var languages: [LatinLanguage] = []
  
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
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OCRLanguageCell")
    tableView.tableFooterView = UIView()
  }

  func prepare(with viewModel: OCRLanguagesViewModel) {
    navigationItem.title = viewModel.title
    languages = viewModel.languages
    
    setupCells(with: viewModel)
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.reloadData()
  }
  
  private func setupCells(with viewModel: OCRLanguagesViewModel) {
    if viewModel.isOn {
      let rows: [Row & RowStyle] = viewModel.languages.compactMap {
        NavigationRow(text: $0.name, detailText: .none, icon: .image($0.flag!))
      }
      
      tableContents = [
        Section(title: "", rows: [
          SwitchRow(text: "Auto Text Recognition", detailText: .subtitle("Example subtitle"),
                    switchValue: viewModel.isOn, icon: .image(UIImage(systemName: "star.square.fill")!),
                    action: didToggleSwitch()),
        ], footer: "Recognizes text in your scans, allows to create PDF text and makes content searchable."),
        
        Section(title: "Recognizes text in these languages", rows: rows)
      ]
    } else {
      tableContents = [
        Section(title: "Recognizes text in these languages", rows: [
          SwitchRow(text: "Auto Text Recognition", detailText: .subtitle("Example subtitle"),
                    switchValue: viewModel.isOn, icon: .image(UIImage(systemName: "star.square.fill")!),
                    action: didToggleSwitch())
        ], footer: "Recognizes text in your scans, allows to create PDF text and makes content searchable.")
      ]
    }
  }
  
  private func didToggleSwitch() -> (Row) -> Void {
    return { [weak self] in
      if let row = $0 as? SwitchRowCompatible {
        let state = "\(row.text) = \(row.switchValue)"
        self?.presenter.toggleLanguages()
      }
    }
  }
  
  // MARK: - UITableViewDataSource
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    cell.imageView?.adjustsImageSizeForAccessibilityContentSizeCategory = true
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    super.tableView(tableView, didSelectRowAt: indexPath)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    60.0
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return super.tableView.headerView(forSection: section)
  }
}

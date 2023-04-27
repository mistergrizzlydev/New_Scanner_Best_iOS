import UIKit

final class BaseWindow: UIWindow { }

enum Appearance: String, CaseIterable {
  case system
  case light
  case dark
  
  var name: String {
    return rawValue.capitalized
  }
  
  func apply() {
    switch self {
    case .system:
      UserDefaults.appearance = .system
      apply(with: .unspecified)
    case .light:
      UserDefaults.appearance = .light
      apply(with: .light)
    case .dark:
      UserDefaults.appearance = .dark
      apply(with: .dark)
    }
  }
  
  private func apply(with overrideUserInterfaceStyle: UIUserInterfaceStyle) {
    if let mainWindow = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .flatMap({ $0.windows })
        .first(where: { $0.isKeyWindow }) {
      mainWindow.overrideUserInterfaceStyle = overrideUserInterfaceStyle
    }
  }
  
  var overrideUserInterfaceStyle: UIUserInterfaceStyle {
    switch self {
    case .system: return .unspecified
    case .light: return .light
    case .dark: return .dark
    }
  }
}
/*
protocol SelectableViewControllerDelegate: AnyObject {
  func didSelectItemAt(_ indexPath: IndexPath, option: String)
}

final class SelectableViewController1: UITableViewController {
  private let options: [String]
  private var selectedOption: String
  weak var selectableDelegate: SelectableViewControllerDelegate?

  init(with title: String, options: [String], selectedOption: String) {
    self.options = options
    self.selectedOption = selectedOption
    
    if #available(iOS 13.0, *) {
      super.init(style: .insetGrouped)
    } else {
      super.init(style: .grouped)
    }
    
    self.navigationItem.title = title
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
    tableView.tableFooterView = UIView()
    tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    tableView.scrollIndicatorInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    tableView.reloadData()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return options.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
    let option = options[indexPath.row]
    cell.textLabel?.text = option
    cell.accessoryType = option.lowercased() == selectedOption.lowercased() ? .checkmark : .none
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedOption = options[indexPath.row]
    self.selectedOption = selectedOption
    tableView.reloadData()

    if let appearance = Appearance(rawValue: selectedOption.lowercased()) {
      appearance.apply()
    }
    
    selectableDelegate?.didSelectItemAt(indexPath, option: selectedOption)
  }
}
*/

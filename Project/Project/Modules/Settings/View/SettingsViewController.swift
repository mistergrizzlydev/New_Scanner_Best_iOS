import UIKit
import QuickTableViewController

protocol SettingsViewControllerProtocol: AnyObject {
  func prepare(with viewModel: SettingsViewModel)
}

class SettingsViewController: QuickTableViewController, SettingsViewControllerProtocol {
  var presenter: SettingsPresenterProtocol!
  
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
  
  private let debugging = Section(title: nil, rows: [NavigationRow(text: "", detailText: .none)])
  
  private func setupViews() {
    // Setup views
    
    let gearImage = UIImage(systemName: "gearshape")!
    let globeImage = UIImage(systemName: "globe")!
    let timeImage = UIImage(systemName: "clock")!
    
    tableContents = [
      Section(title: "Switch", rows: [
        SwitchRow(text: "Setting 1", detailText: .subtitle("Example subtitle"), switchValue: true, icon: .image(globeImage), action: didToggleSwitch()),
        SwitchRow(text: "Setting 2", switchValue: false, icon: .image(timeImage), action: didToggleSwitch())
      ]),
      
      /*
       textLabel?.numberOfLines = 0
       textLabel?.textAlignment = .center
       textLabel?.textColor = tintColor
       */
      Section(title: "Tap Action", rows: [
        //        TapActionRow(text: "Tap action", action: showAlert())
        TapActionRow(text: "Demo", action: { row in
          
        }),
        NavigationRow<MenuTableViewCell>(text: "Tap action", detailText: .none, action: { row in
          print(111)
          
        })
      ]),
      
      Section(title: "Navigation", rows: [
        NavigationRow(text: "CellStyle.default", detailText: .none, icon: .image(gearImage)),
        NavigationRow(text: "CellStyle", detailText: .subtitle(".subtitle"), icon: .image(globeImage), accessoryButtonAction: showDetail()),
        NavigationRow(text: "CellStyle", detailText: .value1(".value1"), icon: .image(timeImage), action: showDetail()),
        NavigationRow(text: "CellStyle", detailText: .value2(".value2"))
      ], footer: "UITableViewCellStyle.Value2 hides the image view."),
      
      RadioSection(title: "Radio Buttons", options: [
        OptionRow(text: "Option 1", isSelected: true, action: didToggleSelection()),
        OptionRow(text: "Option 2", isSelected: false, action: didToggleSelection()),
        OptionRow(text: "Option 3", isSelected: false, action: didToggleSelection())
      ], footer: "See RadioSection for more details."),
      
      debugging
    ]
  }
  
  func prepare(with viewModel: SettingsViewModel) {
    title = viewModel.title
  }
  
  // MARK: - UITableViewDataSource
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    // Alter the cells created by QuickTableViewController
    if #available(iOS 11.0, *) {
      cell.imageView?.adjustsImageSizeForAccessibilityContentSizeCategory = true
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    super.tableView(tableView, didSelectRowAt: indexPath)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
//  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//      // if accessory view of the cell is a custom view
//      let accessoryView = tableView.cellForRow(at: indexPath)?.accessoryView
//
//      // if accessory view of the cell is NOT a custom view (method NOT safe)
//      // let accessoryView = self.tableView(tableView, accessoryButtonForRowAt: indexPath)
//
//      self.performSegue(withIdentifier: "ShowPopover", sender: accessoryView)
//  }

  func tableView(_ tableView: UITableView, accessoryButtonForRowAt indexPath: IndexPath) -> UIView? {
      var result: UIView? = nil
      if let cell = tableView.cellForRow(at: indexPath), let cellScrollView = cell.subviews.first {
          for v in cellScrollView.subviews {
              if NSStringFromClass(type(of: v)) == "UIButton" {
                  result = v
                  break
              }
          }
      }
      return result
  }

  // MARK: - Private Methods
  
  private func didToggleSelection() -> (Row) -> Void {
    return { [weak self] in
      if let option = $0 as? OptionRowCompatible {
        let state = "\(option.text) is " + (option.isSelected ? "selected" : "deselected")
        self?.showDebuggingText(state)
      }
    }
  }
  
  private func didToggleSwitch() -> (Row) -> Void {
    return { [weak self] in
      if let row = $0 as? SwitchRowCompatible {
        let state = "\(row.text) = \(row.switchValue)"
        self?.showDebuggingText(state)
      }
    }
  }
  
  private func showAlert() -> (Row) -> Void {
    return { [weak self] _ in
      let alert = UIAlertController(title: "Action Triggered", message: nil, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
        //        self?.dismiss(animated: true, completion: nil)
      })
      self?.present(alert, animated: true, completion: nil)
    }
  }
  
  private func showDetail() -> (Row) -> Void {
    return { [weak self] in
      let detail = $0.text + ($0.detailText?.text ?? "")
      let controller = UIViewController()
      controller.view.backgroundColor = .white
      controller.title = detail
      self?.navigationController?.pushViewController(controller, animated: true)
      self?.showDebuggingText(detail + " is selected")
    }
  }
  
  private func showDebuggingText(_ text: String) {
    print(text)
    debugging.rows = [NavigationRow(text: text, detailText: .none)]
    if let section = tableContents.firstIndex(where: { $0 === debugging }) {
      tableView.reloadSections([section], with: .none)
    }
  }
}

class MenuTableViewCell: UITableViewCell {
  let accessoryButton = UIButton(type: .system)
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    let noAction = UIAction(title: "No") { _ in
      
    }
    let yesAction = UIAction(title: "Yes") { _ in
      
    }
    let menu = UIMenu(title: "", children: [noAction, yesAction])
    accessoryButton.menu = menu
    accessoryView = accessoryButton
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func showMenu(sender: UIButton) {
    let noAction = UIAction(title: "No") { _ in
      sender.setTitle("No", for: .normal)
    }
    let yesAction = UIAction(title: "Yes") { _ in
      sender.setTitle("Yes", for: .normal)
    }
    let menu = UIMenu(title: "", children: [noAction, yesAction])
    let menuController = UIMenuController.shared
    //        menuController.showMenu(from: sender, rect: sender.bounds, in: sender)
    //        menuController.menuItems = [noAction, yesAction]
  }
}

import UIKit
import QuickTableViewController

protocol SettingsViewControllerProtocol: AnyObject {
  func prepare(with viewModel: SettingsViewModel)
}

class SettingsViewController: QuickTableViewController, SettingsViewControllerProtocol {
  var presenter: SettingsPresenterProtocol!
  
  private let theme: Appearance
  
  init() {
    theme = UserDefaults.appearance
    
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
    tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    tableView.scrollIndicatorInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
  }
  
  private func setupCells() {
    let gearImage = UIImage(systemName: "gearshape")!
    let globeImage = UIImage(systemName: "globe")!
    let timeImage = UIImage(systemName: "clock")!
    
    tableContents = [
      Section(title: "", rows: [
        NavigationRow(text: "TurboScan™ Ultra", detailText: .none, icon: .image(UIImage(systemName: "star.square.fill")!), action: showOnPlusTapped()),
      ], footer: "Get more out of your scanner app with our Plus version! Upgrade now to enjoy advanced features and more options."),
      
      //SortType
      Section(title: "OCR", rows: [
        NavigationRow(text: "Text Recognition (OCR)", detailText: .value1(UserDefaults.isOCREnabled ? "On" : "Off"),
                      icon: .image(UIImage(systemName: "square.text.square.fill")!), action: showOCRLanguagesTapped()), //  text.viewfinder
        NavigationRow(text: "Scan Compression", detailText: .value1(UserDefaults.imageCompressionLevel.name),
                      icon: .image(UIImage(systemName: "arrow.up.and.down.square.fill")!), action: showOnScanCompressionTapped()), // rectangle.compress.vertical
        NavigationRow(text: "Default Page Size", detailText: .value1(UserDefaults.pageSize.name),
                      icon: .image(UIImage(systemName: "rectangle.on.rectangle.square.fill")!), action: showDefaultPageSizeTapped()),
        NavigationRow(text: "Default Name", detailText: .none, icon: .image(UIImage(systemName: "a.square.fill")!), action: showOnPlusTapped()),
        
        SwitchRow(text: "Distortion Correction", detailText: DetailText.none,
                  switchValue: UserDefaults.isDistorsionEnabled, icon: .image(UIImage(systemName: "square.stack.3d.down.right.fill")!),
                  action: didToggleDisortionCorrectionSwitch()),
        
        SwitchRow(text: "Camera Stabilization", detailText: DetailText.none,
                  switchValue: UserDefaults.isCameraStabilizationEnabled, icon: .image(UIImage(systemName: "dot.square.fill")!),
                  action: didToggleCameraStabilizationSwitch()),
      
      ], footer: "Learn more about our app, make requests, and stay informed about our policies!"),
      
      Section(title: "Customizations", rows: [
        NavigationRow(text: "Appearance", detailText: .value1(UserDefaults.appearance.name), icon: .image(UIImage(systemName: "sparkles.square.filled.on.square")!), action: showAppearance()),
      ], footer: "Switch between light, dark, or system appearance modes. Change the appearance of the app to match your style preferences!"),
      
      Section(title: "Help", rows: [
        NavigationRow(text: "Get Support", detailText: .subtitle(AppConfiguration.Help.support.rawValue), icon: .image(UIImage(systemName: "square.and.pencil.circle.fill")!), action: onSupportTapped()),
        NavigationRow(text: "Feature Requests", detailText: .value1("🤟"), icon: .image(UIImage(systemName: "lightbulb.circle.fill")!), action: onFeatureRequestTapped()),
        NavigationRow(text: "Tell a Friend", detailText: .value1("❤️"), icon: .image(UIImage(systemName: "heart.text.square.fill")!), action: onTellAFriendTapped()),
        
        NavigationRow(text: "Privacy Policy", detailText: .none, icon: .image(UIImage(systemName: "hand.raised.square.fill")!), action: showPPTapped()),
        NavigationRow(text: "Terms and Conditions", detailText: .none, icon: .image(UIImage(systemName: "checkmark.shield.fill")!), action: showTaCTapped()),
      ], footer: "Learn more about our app, make requests, and stay informed about our policies!"),
      
      Section(title: "About", rows: [
        NavigationRow(text: "Rate TurboScan™", detailText: .none, icon: .image(UIImage(systemName: "star.square.on.square.fill")!), action: onRateTapped()),
        NavigationRow(text: "What's New", detailText: .none, icon: .image(UIImage(systemName: "bookmark.square.fill")!), action: onWhatsNewTapped()),
        NavigationRow(text: "More Apps", detailText: .none, icon: .image(UIImage(systemName: "square.stack.3d.up.fill")!), action: onMoreAppsTapped()),
      ], footer: "Get more out of your scanner app with our Plus version! Upgrade now to enjoy advanced features and more options.")
      
      /*
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
      */
    ]
  }
 
  private func showOnPlusTapped() -> (Row) -> Void {
    return { [weak self] row in
     
    }
  }
  
  private func onRateTapped() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.onRateTapped()
    }
  }
  
  private func onWhatsNewTapped() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.onWhatsNewTapped()
    }
  }
  
  private func onMoreAppsTapped() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.onMoreAppsTapped()
    }
  }
  
  private func onSupportTapped() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.showEmail(with: .support)
    }
  }
  
  private func onFeatureRequestTapped() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.showEmail(with: .featureRequeast)
    }
  }
  
  private func onTellAFriendTapped() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.showEmail(with: .tellAFriend)
    }
  }
  
  private func showPPTapped() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.onPPTapped()
    }
  }
  
  private func showTaCTapped() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.onTermsTapped()
    }
  }
  
  private func showDefaultPageSizeTapped() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.showPageSize()
    }
  }
  
  private func showOnScanCompressionTapped() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.showScanCompression()
    }
  }
  
  private func showOCRLanguagesTapped() -> (Row) -> Void {
    return { [weak self] row in
      let controller = OCRLanguagesBuilder().buildViewController()!
      self?.navigationController?.pushViewController(controller, animated: true)
    }
  }
  
  private func showAppearance() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.showAppearance()
    }
  }
  
  func prepare(with viewModel: SettingsViewModel) {
    title = viewModel.title
    setupCells()
  }
  
  // MARK: - UITableViewDataSource
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    if #available(iOS 11.0, *) {
      cell.imageView?.adjustsImageSizeForAccessibilityContentSizeCategory = true
      cell.imageView?.tintColor = .themeColor
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
  
  private func didTapOnThemeToggle() -> (Row) -> Void {
    return { [weak self] in
      if let option = $0 as? OptionRowCompatible {
        let state = "\(option.text) is " + (option.isSelected ? "selected" : "deselected")
        self?.showDebuggingText(state)
        
        let appearance = Appearance(rawValue: option.text.lowercased()) ?? .system
        appearance.apply()
      }
    }
  }
  
  private func didToggleCameraStabilizationSwitch() -> (Row) -> Void {
    return { [weak self] in
      if let row = $0 as? SwitchRowCompatible {
        let state = "\(row.text) = \(row.switchValue)"
        self?.showDebuggingText(state)
        self?.presenter.onCameraStabilizationTapped()
      }
    }
  }
  
  private func didToggleDisortionCorrectionSwitch() -> (Row) -> Void {
    return { [weak self] in
      if let row = $0 as? SwitchRowCompatible {
        let state = "\(row.text) = \(row.switchValue)"
        self?.showDebuggingText(state)
        self?.presenter.onDistortionTapped()
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

//extension SettingsViewController: SelectableViewControllerDelegate {
//  func didSelectItemAt(_ indexPath: IndexPath, option: String) {
//    setupViews()
//    tableView.reloadData()
//  }
//}



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


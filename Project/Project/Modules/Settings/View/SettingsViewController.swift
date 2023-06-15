import UIKit
import QuickTableViewController

protocol SettingsViewControllerProtocol: AnyObject {
  func prepare(with viewModel: SettingsViewModel)
}

final class SettingsViewController: QuickTableViewController, SettingsViewControllerProtocol {
  var presenter: SettingsPresenterProtocol!
  private let debugging = Section(title: nil, rows: [NavigationRow(text: "", detailText: .none)])
  
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
  }
  
  private func setupCells() {
    let imageConfig = UIImage.SymbolConfiguration(pointSize: 23, weight: .regular)
    let profileImageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
    let profileImage = UIImage(systemName: "person.circle.fill", withConfiguration: profileImageConfig)
    
    let isPro = true
    let email = UserDefaults.emailFromAccount.isEmpty ? "Not set yet" : "(\(UserDefaults.emailFromAccount))"
//    let securityIcon = UIDevice.current.biometricType == .faceID ? "faceid" : "touchid"
    tableContents = [
//      SettingsSection(title: "", rows: [
//        SettingsNavigationRow(text: "TurboScan™ Ultra", detailText: .none, icon: .image(UIImage(systemName: "star.square.fill", withConfiguration: imageConfig)!),
//                              isPro: AppManager.isProVersion, action: showOnPlusTapped()),
//      ].filter { $0.isPro }, footer: "Get more out of your scanner app with our Plus version! Upgrade now to enjoy advanced features and more options.", isPro: AppManager.isProVersion),
      
      SettingsSection(title: "", rows: [
        SettingsNavigationRow(text: UserDefaults.onboardingCategory.settingsCategory, detailText: .subtitle(UserDefaults.onboardingCategory.settingsName),
                              icon: .image(profileImage!),
                              isPro: isPro),
      ], footer: "Your role has been set to \(UserDefaults.onboardingCategory.category). This cannot be changed.", isPro: isPro),
      
      SettingsSection(title: "Scaning", rows: [
        SettingsNavigationRow(text: "Text Recognition (OCR)", detailText: .value1(UserDefaults.isOCREnabled ? "On" : "Off"),
                              icon: .image(UIImage(systemName: "square.text.square.fill", withConfiguration: imageConfig)!),
                              isPro: isPro, action: showOCRLanguagesTapped()),
        
        SettingsNavigationRow(text: "Scanner settings", detailText: .none,
                              icon: .image(UIImage(systemName: "doc.viewfinder.fill", withConfiguration: imageConfig)!),
                              isPro: isPro, action: didNavigateToScanSettings()),
        
      ], footer: "", isPro: isPro),
      
      SettingsSection(title: "Customizations", rows: [
        SettingsNavigationRow(text: "Appearance", detailText: .subtitle(UserDefaults.appearance.name),
                              icon: .image(UIImage(systemName: "sparkles.square.filled.on.square", withConfiguration: imageConfig)!),
                              isPro: isPro, action: showAppearance()),
        
        SettingsNavigationRow(text: "Start App with", detailText: .subtitle(UserDefaults.startType.rawValue),
                              icon: .image(UIImage(systemName: "flag.square.fill", withConfiguration: imageConfig)!),
                              isPro: isPro, action: showStartWith()),
        
        SettingsNavigationRow(text: "Email from account", detailText: .subtitle(email),
                              icon: .image(UIImage(systemName: "person.crop.square.filled.and.at.rectangle.fill", withConfiguration: imageConfig)!), isPro: isPro,
                              accessoryButtonAction: showGrabDefaulEmailAlert()),
      ].filter { $0.isPro }, footer: nil, // "Switch between light, dark, or system appearance modes. Change the appearance of the app to match your style preferences!"
                      isPro: isPro),
      
//      SettingsSection(title: "Security", rows: [
//        SwitchRow(text: UIDevice.current.biometricType.name, detailText: DetailText.none,
//                  switchValue: KeychainManager.default.isAppLocked, icon: .image(UIImage(systemName: "\(securityIcon)", withConfiguration: imageConfig)!),
//                  action: didToggleBiometricAuthSwitch())
//      ], footer: "Unlock app name with \(UIDevice.current.biometricType.name) recognition. You have to set a passcode as a fallback.",
//                      isPro: UIDevice.current.biometricType != .none ),
      
      SettingsSection(title: "Help", rows: [
        SettingsNavigationRow(text: "Get Support", detailText: .subtitle(AppConfiguration.Help.support.rawValue),
                              icon: .image(UIImage(systemName: "square.and.pencil", withConfiguration: imageConfig)!),
                              isPro: isPro, action: onSupportTapped()),
        SettingsNavigationRow(text: "Pass onboarding", detailText: .value1("📲"),
                              icon: .image(UIImage(systemName: "figure.walk.motion", withConfiguration: imageConfig)!),
                              isPro: isPro, action: onOnboardingTapped()),
        SettingsNavigationRow(text: "Feature Requests", detailText: .value1("🤟"),
                              icon: .image(UIImage(systemName: "lightbulb.circle.fill", withConfiguration: imageConfig)!),
                              isPro: isPro, action: onFeatureRequestTapped()),
        SettingsNavigationRow(text: "Tell a Friend", detailText: .value1("❤️"),
                              icon: .image(UIImage(systemName: "heart.text.square.fill", withConfiguration: imageConfig)!),
                              isPro: isPro, action: onTellAFriendTapped()),
        
        SettingsNavigationRow(text: "Privacy Policy", detailText: .none, icon: .image(UIImage(systemName: "hand.raised.square.fill", withConfiguration: imageConfig)!),
                              isPro: isPro, action: showPPTapped()),
        SettingsNavigationRow(text: "Terms and Conditions", detailText: .none, icon: .image(UIImage(systemName: "checkmark.shield.fill", withConfiguration: imageConfig)!),
                              isPro: isPro, action: showTaCTapped()),
      ], footer: "Learn more about our app, make requests, and stay informed about our policies!",
                      isPro: isPro),
      
      SettingsSection(title: "About", rows: [
        SettingsNavigationRow(text: "Rate TurboScan™", detailText: .none, icon: .image(UIImage(systemName: "star.square.fill", withConfiguration: imageConfig)!),
                              isPro: isPro, action: onRateTapped()),
        SettingsNavigationRow(text: "What's New", detailText: .none, icon: .image(UIImage(systemName: "bookmark.square.fill", withConfiguration: imageConfig)!),
                              isPro: isPro, action: onWhatsNewTapped()),
        SettingsNavigationRow(text: "More Apps", detailText: .none, icon: .image(UIImage(systemName: "square.stack.3d.up.fill", withConfiguration: imageConfig)!),
                              isPro: isPro, action: onMoreAppsTapped()),
      ], footer: "",
                      // Get more out of your scanner app with our Plus version! Upgrade now to enjoy advanced features and more options.
                      isPro: isPro),
      
      SettingsSection(title: "", rows: [
        SettingsNavigationRow(text: "TurboScan™ version", detailText: .subtitle(Bundle.appVersion), icon: .image(UIImage(systemName: "crown.fill", withConfiguration: imageConfig)!),
                              isPro: isPro)
      ], footer: "",
                      isPro: isPro)
    ].filter { $0.isPro }
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
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return super.tableView.headerView(forSection: section)
  }
}

// MARK: - Private Methods

extension SettingsViewController {
  
  private func didNavigateToScanSettings() -> (Row) -> Void {
    return { [weak self] _ in
      self?.presenter.navigateToSettings()
    }
  }
  
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
  
//  private func didToggleBiometricAuthSwitch() -> (Row) -> Void {
//    return { [weak self] in
//      if let row = $0 as? SwitchRowCompatible {
//        let state = "\(row.text) = \(row.switchValue)"
//        self?.showDebuggingText(state)
//        // todo
////        KeychainManager.default.isAppLocked.toggle()
//
////        BiometricAuthenticator().authenticate(type: .touchID) { success, error in
////          print(success, error?.localizedDescription)
////          KeychainManager.default.isAppLocked = success
////        }
//
//        SecurityManager().authenticateUser { success in
//          print(success)
//        }
//      }
//    }
//  }
  
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
  
  private func showGrabDefaulEmailAlert() -> (Row) -> Void {
    return { [weak self] _ in
      self?.presenter.grabDefaultEmail()
    }
  }
  
  private func showDebuggingText(_ text: String) {
    debugPrint(text)
    debugging.rows = [NavigationRow(text: text, detailText: .none)]
    if let section = tableContents.firstIndex(where: { $0 === debugging }) {
      tableView.reloadSections([section], with: .none)
    }
  }
}

extension SettingsViewController {
//  private func showOnPlusTapped() -> (Row) -> Void {
//    return { [weak self] row in
//
//    }
//  }
//
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
      self?.presenter.showEmail(with: .support, from: row as? UITableViewCell)
    }
  }
  
  private func onOnboardingTapped() -> (Row) -> Void {
    return { [weak self] row in
      let controller = StoryCollectionViewController(isFirstLaunch: false, fromSettings: true)
      controller.modalPresentationStyle = .fullScreen
      self?.present(controller, animated: true)
    }
  }
  //
  /*
   
   let controller = StoryCollectionViewController()
   controller.modalPresentationStyle = .fullScreen
   */
  
  private func onFeatureRequestTapped() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.showEmail(with: .featureRequeast, from: row as? UITableViewCell)
    }
  }
  
  private func onTellAFriendTapped() -> (Row) -> Void {
    return { [weak self] row in
      let btlv = self?.view.allSubviews().first(where: { $0 is UITableView }) as? UITableView
      self?.presenter.showEmail(with: .tellAFriend, from: (row as? SettingsNavigationRow<UITableViewCell>)?.cell)
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
  
  private func showStartWith() -> (Row) -> Void {
    return { [weak self] row in
      self?.presenter.showStartAppWith()
    }
  }
}

extension SettingsViewController {
  //  private func demoCells() {
  //    let gearImage = UIImage(systemName: "gearshape")!
  //    let globeImage = UIImage(systemName: "globe")!
  //    let timeImage = UIImage(systemName: "clock")!
  //    tableContents = [
  //      Section(title: "Switch", rows: [
  //        SwitchRow(text: "Setting 1", detailText: .subtitle("Example subtitle"), switchValue: true, icon: .image(globeImage), action: didToggleSwitch()),
  //        SwitchRow(text: "Setting 2", switchValue: false, icon: .image(timeImage), action: didToggleSwitch())
  //      ]),
  //
  //      /*
  //       textLabel?.numberOfLines = 0
  //       textLabel?.textAlignment = .center
  //       textLabel?.textColor = tintColor
  //       */
  //      Section(title: "Tap Action", rows: [
  //        //        TapActionRow(text: "Tap action", action: showAlert())
  //        TapActionRow(text: "Demo", action: { row in
  //
  //        })
  //      ]),
  //
  //      Section(title: "Navigation", rows: [
  //        NavigationRow(text: "CellStyle.default", detailText: .none, icon: .image(gearImage)),
  //        NavigationRow(text: "CellStyle", detailText: .subtitle(".subtitle"), icon: .image(globeImage), accessoryButtonAction: showDetail()),
  //        NavigationRow(text: "CellStyle", detailText: .value1(".value1"), icon: .image(timeImage), action: showDetail()),
  //        NavigationRow(text: "CellStyle", detailText: .value2(".value2"))
  //      ], footer: "UITableViewCellStyle.Value2 hides the image view."),
  //
  //      RadioSection(title: "Radio Buttons", options: [
  //        OptionRow(text: "Option 1", isSelected: true, action: didToggleSelection()),
  //        OptionRow(text: "Option 2", isSelected: false, action: didToggleSelection()),
  //        OptionRow(text: "Option 3", isSelected: false, action: didToggleSelection())
  //      ], footer: "See RadioSection for more details."),
  //
  //      debugging
  //    ]
  //  }
}

extension Array where Element == Row & RowStyle {
  func isProversion() -> Bool {
    return AppManager.isProVersion
  }
}

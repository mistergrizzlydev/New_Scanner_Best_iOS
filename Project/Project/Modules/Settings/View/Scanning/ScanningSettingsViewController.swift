import UIKit
import QuickTableViewController

final class ScanningSettingsViewController: QuickTableViewController, SettingsViewControllerProtocol {
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
    }
    
    private func setupViews() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 23, weight: .regular)
        
        tableContents = [
            Section(title: "", rows: [
                NavigationRow(text: "Default Document detection", detailText: .subtitle(UserDefaults.documentDetectionType.name),
                              icon: .image(UIImage(systemName: UserDefaults.documentDetectionType.imageName, withConfiguration: imageConfig)!),
                              action: didShowDocumentDetectionTapped()),
                
                NavigationRow(text: "Default Camera filter", detailText: .subtitle(UserDefaults.cameraFilterType.name),
                              icon: .image(UIImage(systemName: "camera.filters", withConfiguration: imageConfig)!),
                              action: didShowCameraFilterTapped()),
                
                NavigationRow(text: "Default Camera flash", detailText: .subtitle(UserDefaults.cameraFlashType.name),
                              icon: .image(UIImage(systemName: UserDefaults.cameraFlashType.imageName, withConfiguration: imageConfig)!),
                              action: didShowCameraFlashTapped()),
                
                NavigationRow(text: "Scan Compression", detailText: .subtitle(UserDefaults.imageCompressionLevel.name),
                              icon: .image(UIImage(systemName: "arrow.up.and.down.square.fill", withConfiguration: imageConfig)!),
                              action: showOnScanCompressionTapped()),
                
                NavigationRow(text: "Default Page Size", detailText: .subtitle(UserDefaults.pageSize.name),
                              icon: .image(UIImage(systemName: "rectangle.on.rectangle.square.fill", withConfiguration: imageConfig)!),
                              action: showDefaultPageSizeTapped()),
                
//                NavigationRow(text: "Default Smart category", detailText: .subtitle(UserDefaults.documentClasifierCategory.name),
//                              icon: .image(UIImage(systemName: "eye.square.fill", withConfiguration: imageConfig)!),
//                              action: showDefaultDocumentCategoryTapped()),
                
                NavigationRow(text: "Default sort type", detailText: .subtitle(UserDefaults.sortedFilesType.rawValue),
                              icon: .image(UserDefaults.sortedFilesType.settingsImage), action: showDefaultSortTypeTapped()),
                
                NavigationRow(text: "Default Name", detailText: .none, icon: .image(UIImage(systemName: "a.square.fill", withConfiguration: imageConfig)!),
                              action: didSelectDefaultNameTapped()),
                
                SwitchRow(text: "Distortion Correction", detailText: DetailText.none,
                          switchValue: UserDefaults.isDistorsionEnabled, icon: .image(UIImage(systemName: "square.stack.3d.down.right.fill", withConfiguration: imageConfig)!),
                          action: didToggleDisortionCorrectionSwitch()),
                
                SwitchRow(text: "Camera Stabilization", detailText: DetailText.none,
                          switchValue: UserDefaults.isCameraStabilizationEnabled, icon: .image(UIImage(systemName: "dot.square.fill", withConfiguration: imageConfig)!),
                          action: didToggleCameraStabilizationSwitch())
                
            ], footer: "")
        ]
    }
    
    func prepare(with viewModel: SettingsViewModel) {
        title = viewModel.title
        setupViews()
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

extension ScanningSettingsViewController {
    private func didSelectDefaultNameTapped() -> (Row) -> Void {
        return { [weak self] _ in
            self?.presenter.onDefaultNameTapped()
        }
    }
    
    private func didToggleCameraStabilizationSwitch() -> (Row) -> Void {
        return { [weak self] _ in
            self?.presenter.onCameraStabilizationTapped()
        }
    }
    
    private func didToggleDisortionCorrectionSwitch() -> (Row) -> Void {
        return { [weak self] _ in
            self?.presenter.onDistortionTapped()
        }
    }

    private func didShowDocumentDetectionTapped() -> (Row) -> Void {
        return { [weak self] _ in
            self?.presenter.onDocumentDetectionTapped()
        }
    }
    
    private func didShowCameraFilterTapped() -> (Row) -> Void {
        return { [weak self] _ in
            self?.presenter.onCameraFilterTapped()
        }
    }
    
    private func didShowCameraFlashTapped() -> (Row) -> Void {
        return { [weak self] _ in
            self?.presenter.onCameraFlashTapped()
        }
    }

    private func showDefaultPageSizeTapped() -> (Row) -> Void {
        return { [weak self] row in
            self?.presenter.showPageSize()
        }
    }
    
    private func showDefaultSortTypeTapped() -> (Row) -> Void {
        return { [weak self] row in
            self?.presenter.showSortType()
        }
    }
    
    private func showDefaultDocumentCategoryTapped() -> (Row) -> Void {
        return { [weak self] row in
            self?.presenter.showSmartCategories()
        }
    }
    
    private func showOnScanCompressionTapped() -> (Row) -> Void {
        return { [weak self] row in
            self?.presenter.showScanCompression()
        }
    }
}

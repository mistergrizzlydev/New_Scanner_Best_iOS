import UIKit

protocol SmartCategoryViewControllerProtocol: AnyObject {
  func prepare(with viewModels: [SmartCategoryViewModel])
}

final class SmartCategoryViewController: UICollectionViewController, SmartCategoryViewControllerProtocol {
  private struct Constants {
    static let reuseIdentifier = SmartCategoryCollectionViewCell.reuseIdentifier
  }
  
  var presenter: SmartCategoryPresenterProtocol!
  
  private let cellWidth: CGFloat = (UIScreen.main.bounds.width - 120) / 4.0
  private let cellSpacing: CGFloat = 20
  private let sectionInsets = UIEdgeInsets(top: 6, left: 30, bottom: 0, right: 30)
  private let headerReuseIdentifier = "HeaderView"
  
  private var viewModels: [SmartCategoryViewModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }
  
  private func setupViews() {
    navigationItem.title = "Smart Categories"
    navigationItem.largeTitleDisplayMode = .automatic
    navigationController?.navigationBar.prefersLargeTitles = false
    
    let nib = UINib(nibName: Constants.reuseIdentifier, bundle: .main)
    collectionView.register(nib, forCellWithReuseIdentifier: Constants.reuseIdentifier)
    collectionView.alwaysBounceVertical = true
    collectionView.isUserInteractionEnabled = true
    
    collectionView.register(UICollectionReusableView.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: headerReuseIdentifier)
    
    collectionView.contentInsetAdjustmentBehavior = .always
    
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
    button.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .selected)
    button.addTarget(self, action: #selector(showPopover(_:)), for: .touchUpInside)
    let barItem = UIBarButtonItem(customView: button)
    
//    navigationItem.setRightBarButton(barItem, animated: true)
  }
  
  func prepare(with viewModels: [SmartCategoryViewModel]) {
    self.viewModels = viewModels
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.reloadData()
  }
  
  @objc private func showPopover(_ sender: UIButton) {
    sender.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
    
    // Create the table view controller that will be displayed in the popover
    let tableViewController = UIViewController()//MyTableViewController(image: myImage, title: myTitle)
    
    // Set the presentation style and preferred size of the popover
    tableViewController.modalPresentationStyle = .popover
    tableViewController.preferredContentSize = CGSize(width: 200, height: 200)
    
    // Set the source view and source rect for the popover
    tableViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
    
    // Set the arrow direction of the popover
    tableViewController.popoverPresentationController?.permittedArrowDirections = .up
    
    // Present the popover
    present(tableViewController, animated: true, completion: nil)
  }
}

// MARK: UICollectionViewDataSource && UICollectionViewDelegateFlowLayout

extension SmartCategoryViewController: UICollectionViewDelegateFlowLayout {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModels.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifier,
                                                        for: indexPath) as? SmartCategoryCollectionViewCell else {
      return UICollectionViewCell()
    }
    cell.configure(with: viewModels[indexPath.row])
    return cell
  }
  
  // MARK: UICollectionViewDelegateFlowLayout
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: cellWidth, height: 102)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    6
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    cellSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 44)
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath)
    let label = UILabel(frame: CGRect(x: sectionInsets.left, y: 10, width: collectionView.bounds.width - sectionInsets.left - sectionInsets.right, height: 44))
    label.text = "Choose the right category for your document"
    label.font = .systemFont(ofSize: 15, weight: .regular)
    label.textColor = .labelColor
    label.numberOfLines = 2
    headerView.addSubview(label)
    return headerView
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    presenter.didSelectOnCategory(at: indexPath.row)
  }
}

import UIKit

protocol RearrangeViewControllerProtocol: AnyObject {
  func prepare(with viewModels: [RearrangeViewModel])
}

final class RearrangeViewController: UICollectionViewController, RearrangeViewControllerProtocol {
  var presenter: RearrangePresenterProtocol!
  
  private var viewModels: [RearrangeViewModel] = []
  private var isLongPressedEnabled: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }
  
  private func setupViews() {
    // Setup views
    navigationItem.title = "Rearrange pages"
    
    setupCollectionView()
  }
  
  private func setupCollectionView() {
    let nib = UINib(nibName: RearrangeCollectionViewCell.reuseIdentifier, bundle: .main)
    collectionView.register(nib, forCellWithReuseIdentifier: RearrangeCollectionViewCell.reuseIdentifier)
    collectionView.alwaysBounceVertical = true
    collectionView.isUserInteractionEnabled = true
    
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
    collectionView.addGestureRecognizer(longPressGesture)
    
    navigationItem.setRightBarButton(editButtonItem, animated: true)
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    isLongPressedEnabled = editing
    
    collectionView.reloadData()
  }
  
  func prepare(with viewModels: [RearrangeViewModel]) {
    self.viewModels = viewModels
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.reloadData()
  }
  
  @objc private func longTap(_ gesture: UIGestureRecognizer){
    guard isLongPressedEnabled else { return }
    switch(gesture.state) {
    case .began:
      guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
        return
      }
      collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
    case .changed:
      collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
    case .ended:
      collectionView.endInteractiveMovement()
      isLongPressedEnabled = true
      self.collectionView.reloadData()
    default:
      collectionView.cancelInteractiveMovement()
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModels.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RearrangeCollectionViewCell.reuseIdentifier,
                                                        for: indexPath) as? RearrangeCollectionViewCell else {
      return UICollectionViewCell()
    }
    
    cell.configure(with: viewModels[indexPath.row])
    
    if isLongPressedEnabled {
      cell.startAnimate()
    } else {
      cell.stopAnimate()
    }
    
    return cell
  }
}

extension RearrangeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let collectionViewWidth = collectionView.bounds.width
      let numberOfColumns: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 5 : 3 // iPad will have 5 columns, iPhone will have 3
      let itemWidth = (collectionViewWidth - (numberOfColumns + 1) * 10) / numberOfColumns // Subtracting the spacing from the available width and then dividing by the number of columns
      let itemHeight = itemWidth * 1.5 // A 3:2 aspect ratio for the thumbnail
      return CGSize(width: itemWidth, height: itemHeight + 20) // Add 20 for the label height
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
  }

  override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool { collectionView.isEditing }
  
  override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {    
    // Update the order of the underlying data source
    let movedItem = viewModels.remove(at: sourceIndexPath.item)
    viewModels.insert(movedItem, at: destinationIndexPath.item)

    presenter.updatePage(sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
  }
}

import UIKit

private let reuseIdentifier = "StoryCollectionViewCell"

final class StoryCollectionViewController: UIViewController {
  
  private lazy var flowLayout: PagingCollectionViewLayout = {
    let layout = PagingCollectionViewLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = UIScreen.main.bounds.size
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.numberOfItemsPerPage = 1
    return layout
  }()
  
  private lazy var collectionView: UICollectionView = {
    let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
    collection.translatesAutoresizingMaskIntoConstraints = false
    collection.dataSource = self
    collection.delegate = self
    collection.register(StoryCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    collection.bounces = false
    collection.isScrollEnabled = false
    return collection
  }()
  
  private var storiesArray = [Story]()
  private var rowIndex: Int = 0
  
  private var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
  
  private var tapGest: UITapGestureRecognizer!
  private var longPressGest: UILongPressGestureRecognizer!
  private var panGest: UIPanGestureRecognizer!
    
  private lazy var startNowButton: UIButton = {
    let startNowButton = UIButton(type: .system)
    startNowButton.translatesAutoresizingMaskIntoConstraints = false
    
    startNowButton.backgroundColor = UIColor(red: 24/255.0, green: 27/255.0, blue: 30/255.0, alpha: 1.0)
    startNowButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
    startNowButton.layer.cornerRadius = 14
    startNowButton.setTitleColor(.white, for: UIControl.State())
    startNowButton.setTitle(fromSettings ? "I'm Expert!".localized : "Start now".localized, for: UIControl.State())
    startNowButton.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 2, blur: 12, spread: 0)
    startNowButton.addTarget(self, action: #selector(startNowTapped(_:)), for: .touchUpInside)
    return startNowButton
  }()
  
  private var coordinator: MainCoordinator?
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var shouldAutorotate: Bool {
    return false
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  
  private let isFirstLaunch: Bool
  private let fromSettings: Bool
  
  init(isFirstLaunch: Bool = false, fromSettings: Bool) {
    self.isFirstLaunch = isFirstLaunch
    self.fromSettings = fromSettings
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(collectionView)
    
    let top = collectionView.topAnchor.constraint(equalTo: view.topAnchor)
    let bottom = collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    let left = collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
    let right = collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    
    NSLayoutConstraint.activate([top, bottom, left, right])
    
    startNowButton.alpha = 0
    view.addSubview(startNowButton)
    startNowButton.bringSubviewToFront(view)
    let margin: CGFloat = isiPhone ? 32 : 64
    
    NSLayoutConstraint.activate([
      startNowButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: margin),
      startNowButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -margin),
      startNowButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
      startNowButton.heightAnchor.constraint(equalToConstant: 50)
    ])
    
    view.layoutIfNeeded()
    
    setupModel()
    addGesture()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    collectionView.reloadData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let storyBar = getCurrentStory() {
      storyBar.startAnimation()
    }
  }
  
  private func setupModel() {
    let viewModels = StoryItem.getDummyData()
    storiesArray = [Story(items: viewModels)]
    Story.userIndex = rowIndex
    collectionView.reloadData()
    collectionView.scrollToItem(at: IndexPath(item: Story.userIndex, section: 0),
                                at: .centeredHorizontally, animated: false)
  }
  
  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)
    flowLayout.invalidateLayout()
    
    //scroll to indexPath after the rotation is going
    let indexPath = IndexPath(item: Story.userIndex, section: 0)
    
    DispatchQueue.main.async {
      self.collectionView.reloadItems(at: [indexPath])
      self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
      self.collectionView.reloadData()
      self.collectionView.layoutIfNeeded()
      self.view.layoutIfNeeded()
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    flowLayout.itemSize = UIScreen.main.bounds.size
  }
}

extension StoryCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    return storiesArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                  for: indexPath) as! StoryCollectionViewCell
    cell.weakParent = self
    cell.configure(with: storiesArray[indexPath.row])
    return cell
  }
}

// MARK:- Helper Methods
extension StoryCollectionViewController {
  
  func currentStoryIndexChanged(index: Int) {
    storiesArray[Story.userIndex].storyIndex = index
    showStartNowButton(at: index)
  }
  
  func showNextUserStory() {
    let newUserIndex = Story.userIndex + 1
    if newUserIndex < storiesArray.count {
      Story.userIndex = newUserIndex
      showUpcomingUserStory()
    } else {
      // Dismiss
      //cancelBtnTouched()
    }
  }
  
  func showPreviousUserStory() {
    let newIndex = Story.userIndex - 1
    if newIndex >= 0 {
      Story.userIndex = newIndex
      showUpcomingUserStory()
    } else {
      // Dismiss
      //cancelBtnTouched()
    }
  }
  
  func showUpcomingUserStory() {
    removeGestures()
    let indexPath = IndexPath(item: Story.userIndex, section: 0)
    collectionView.reloadItems(at: [indexPath])
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      if let storyBar = self.getCurrentStory() {
        storyBar.animate(animationIndex: self.storiesArray[Story.userIndex].storyIndex)
        self.addGesture()
      }
    }
  }
  
  private func getCurrentStory() -> SegmentedProgressBar? {
    if let cell = collectionView.cellForItem(at: IndexPath(item: Story.userIndex, section: 0)) as? StoryCollectionViewCell {
      return cell.getStoryBar()
    }
    return nil
  }
  
  private func showStartNowButton(at index: Int) {
    let needsToShowButton = isFirstLaunch ? index == storiesArray[0].items.count-1 : index >= 3
    if needsToShowButton {
      if startNowButton.alpha == 0 {
        startNowButton.alpha = 1.0
      }
    } else {
      startNowButton.alpha = 0
    }
  }
  
  @objc private func startNowTapped(_ sender: UIButton) {
    if fromSettings {
      self.dismiss(animated: true)
    } else {
      self.dismiss(animated: true) {
        let controller = OnboardingBuilder().buildViewController()!
        controller.modalPresentationStyle = .fullScreen
        self.setRootViewController(controller)
      }
    }
  }
}

extension UIViewController {
  func setRootViewController(_ viewController: UIViewController) {
    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
      sceneDelegate.window?.rootViewController = viewController
      sceneDelegate.window?.makeKeyAndVisible()
    }
  }
}


// MARK:- Gestures
extension StoryCollectionViewController {
  
  private func addGesture() {
    // for previous and next navigation
    tapGest = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    self.view.addGestureRecognizer(tapGest)
    
    longPressGest = UILongPressGestureRecognizer(target: self,
                                                 action: #selector(panGestureRecognizerHandler))
    longPressGest.minimumPressDuration = 0.2
    view.addGestureRecognizer(longPressGest)
    
    /*
     swipe down to dismiss
     NOTE: Self's presentation style should be "Over Current Context"
     */
    //    panGest = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler))
    //    self.view.addGestureRecognizer(panGest)
  }
  
  private func removeGestures() {
    self.view.removeGestureRecognizer(tapGest)
    self.view.removeGestureRecognizer(longPressGest)
    self.view.removeGestureRecognizer(panGest)
  }
  
  @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    let touchLocation: CGPoint = gesture.location(in: gesture.view)
    let maxLeftSide = ((view.bounds.maxX * 40) / 100) // Get 40% of Left side
    if let storyBar = getCurrentStory() {
      if touchLocation.x < maxLeftSide {
        storyBar.previous()
      } else {
        storyBar.next()
      }
    }
  }
  
  @objc private func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
    guard let storyBar = getCurrentStory() else { return }
    
    let touchPoint = sender.location(in: self.view?.window)
    if sender.state == .began {
      storyBar.pause()
      initialTouchPoint = touchPoint
    } else if sender.state == .changed {
      if touchPoint.y - initialTouchPoint.y > 0 {
        self.view.frame = CGRect(x: 0, y: max(0, touchPoint.y - initialTouchPoint.y),
                                 width: self.view.frame.size.width,
                                 height: self.view.frame.size.height)
      }
    } else if sender.state == .ended || sender.state == .cancelled {
      if touchPoint.y - initialTouchPoint.y > 200 {
        dismiss(animated: true, completion: nil)
      } else {
        storyBar.resume()
        UIView.animate(withDuration: 0.3, animations: {
          self.view.frame = CGRect(x: 0, y: 0,
                                   width: self.view.frame.size.width,
                                   height: self.view.frame.size.height)
        })
      }
    }
  }
}

// MARK:- Scroll View Delegate
extension StoryCollectionViewController {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if let storyBar = getCurrentStory() {
      storyBar.pause()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let lastIndex = Story.userIndex
    let pageWidth = collectionView.frame.size.width
    let pageNo = Int(floor(((collectionView.contentOffset.x + pageWidth / 2) / pageWidth)))
    
    if lastIndex != pageNo {
      Story.userIndex = pageNo
      showUpcomingUserStory()
    } else {
      if let storyBar = getCurrentStory() {
        self.addGesture()
        storyBar.resume()
      }
    }
  }
}

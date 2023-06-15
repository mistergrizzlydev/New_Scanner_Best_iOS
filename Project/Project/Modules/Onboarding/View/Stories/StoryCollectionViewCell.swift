//
//  StoryCollectionViewCell.swift
//  StoriesKit
//
//  Created by Elyscan.app on 2/26/21.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {
  
  private let cellReuseIdentifier = "Story2CollectionViewCell"
  
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
    collection.register(UINib(nibName: cellReuseIdentifier, bundle: .main), forCellWithReuseIdentifier: cellReuseIdentifier)
    collection.bounces = false
    collection.isScrollEnabled = false
    return collection
  }()
  
  private var storyBar: SegmentedProgressBar?
    
  private var story: Story?
  weak var weakParent: StoryCollectionViewController?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
  }
  
  private func setupViews() {
    addSubview(collectionView)
    let top = collectionView.topAnchor.constraint(equalTo: topAnchor)
    let bottom = collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let left = collectionView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let right = collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
    
    NSLayoutConstraint.activate([top, bottom, left, right])
  }
  
  func configure(with story: Story) {
    self.story = story
    addStoryBar()
    contentView.layoutIfNeeded()
    collectionView.reloadData()
    collectionView.scrollToItem(at: IndexPath(item: story.storyIndex, section: 0), at: .centeredHorizontally, animated: false)
  }
  
  private func addStoryBar() {
    if let _ = storyBar {
      storyBar?.removeFromSuperview()
      storyBar = nil
    }
    guard let story = story else { return }
    
    storyBar = SegmentedProgressBar(numberOfSegments: story.items.count)
    
    guard let storyBar = storyBar, let weakParent = weakParent?.view else { return }
    storyBar.frame = CGRect(x: 16, y: 24, width: weakParent.frame.width - (16+24), height: 4)
    
    storyBar.delegate = self
    storyBar.animatingBarColor = UIColor.white
    storyBar.nonAnimatingBarColor = UIColor.white.withAlphaComponent(0.25)
    storyBar.padding = 2
    storyBar.resetSegmentsTill(index: story.storyIndex)
    
    weakParent.addSubview(storyBar)
  }
  
  func getStoryBar() -> SegmentedProgressBar? {
    return storyBar
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    guard let storyBar = storyBar, let weakParent = weakParent?.view else { return }
    storyBar.frame = CGRect(x: 16, y: 24, width: weakParent.frame.width - (16+24), height: 4)
  }
}

extension StoryCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    return story?.items.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier,
                                                  for: indexPath) as! Story2CollectionViewCell
    
    if let viewModel = story?.items[indexPath.row] {
      cell.setup(with: viewModel)
    }
    
    return cell
  }
}

// MARK:- Segmented ProgressBar Delegate
extension StoryCollectionViewCell: SegmentedProgressBarDelegate {
  
  func segmentedProgressBarChangedIndex(index: Int) {
    weakParent?.currentStoryIndexChanged(index: index)
    collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                at: .centeredHorizontally, animated: false)
  }
  
  func segmentedProgressBarReachEnd() {
    weakParent?.showNextUserStory()
  }
  
  func segmentedProgressBarReachPrevious() {
    weakParent?.showPreviousUserStory()
  }
}

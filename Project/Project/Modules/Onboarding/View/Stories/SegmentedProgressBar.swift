//
//  SegmentedProgressBar.swift
//  StoriesKit
//
//  Created by Elyscan.app on 2/26/21.
//

import UIKit

class SegmentBar {
  let nonAnimatingBarView = UIView()
  let animatingBarView = UIView()
}

protocol SegmentedProgressBarDelegate: AnyObject {
  func segmentedProgressBarChangedIndex(index: Int)
  func segmentedProgressBarReachEnd()
  func segmentedProgressBarReachPrevious()
}

class SegmentedProgressBar: UIView {
  
  weak var delegate: SegmentedProgressBarDelegate?
  
  var animatingBarColor = UIColor.gray {
    didSet {
      updateColors()
    }
  }
  
  var nonAnimatingBarColor = UIColor.gray.withAlphaComponent(0.25) {
    didSet {
      updateColors()
    }
  }
  
  var padding: CGFloat = 2.0
  var height: CGFloat = 2.5
  let duration: TimeInterval
  
  private var segments = [SegmentBar]()
  private var currentAnimationIndex = 0
  private var barAnimation: UIViewPropertyAnimator?
  
  init(numberOfSegments: Int, duration: TimeInterval = 5.0) {
    self.duration = duration
    super.init(frame: CGRect.zero)
    
    for _ in 0..<numberOfSegments {
      let segment = SegmentBar()
      addSubview(segment.nonAnimatingBarView)
      addSubview(segment.animatingBarView)
      segments.append(segment)
    }
    updateColors()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    stop()
  }
  
  private func updateColors() {
    for segment in segments {
      segment.animatingBarView.backgroundColor = animatingBarColor
      segment.nonAnimatingBarView.backgroundColor = nonAnimatingBarColor
    }
  }
  
  private func getYPosition() -> CGFloat {
    let key = UIWindow.key
    return key?.safeAreaInsets.bottom ?? 0
  }
}

// MARK: - Playback

extension SegmentedProgressBar {
  
  func resetSegmentFrames() {
    let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
    for (index, segment) in segments.enumerated() {
      let segFrame = CGRect(x: CGFloat(index) * (width + padding),
                            y: getYPosition(),
                            width: width,
                            height: height)
      segment.nonAnimatingBarView.frame = segFrame
      segment.animatingBarView.frame = CGRect(origin: segFrame.origin,
                                          size: CGSize(width: 0, height: height))
      
      let cr = frame.height / 2
      segment.nonAnimatingBarView.layer.cornerRadius = cr
      segment.animatingBarView.layer.cornerRadius = cr
    }
  }
  
  func resetSegmentsTill(index: Int) {
    var resetTillIndex = index
    stop()
    
    if resetTillIndex > segments.count - 1 {
      resetTillIndex = segments.count - 1
    }
    
    currentAnimationIndex = resetTillIndex
    resetSegmentFrames()
    for segmentIdx in 0..<resetTillIndex {
      segments[segmentIdx].animatingBarView.frame.size.width = segments[segmentIdx].nonAnimatingBarView.frame.size.width
    }
  }
  
  func removeOldAnimation(newWidth: CGFloat = 0) {
    stop()
    let oldAnimatingBar = segments[currentAnimationIndex].animatingBarView
    oldAnimatingBar.frame.size.width = newWidth
  }
  
  func previous() {
    removeOldAnimation()
    let newIndex = currentAnimationIndex - 1
    if newIndex < 0 {
      currentAnimationIndex = 0
      animate() // start again
      delegate?.segmentedProgressBarReachPrevious()
    } else {
      currentAnimationIndex = newIndex
      removeOldAnimation()
      delegate?.segmentedProgressBarChangedIndex(index: newIndex)
      animate(animationIndex: newIndex)
    }
  }
  
  func next() {
    let newIndex = currentAnimationIndex + 1
    if newIndex < segments.count {
      let oldSegment = segments[currentAnimationIndex]
      removeOldAnimation(newWidth: oldSegment.nonAnimatingBarView.frame.width)
      delegate?.segmentedProgressBarChangedIndex(index: newIndex)
      animate(animationIndex: newIndex)
    } else {
      delegate?.segmentedProgressBarReachEnd()
    }
  }
}

// MARK: - Animations

extension SegmentedProgressBar {
  func showStoryBar() {
    if self.alpha == 0 {
      UIView.animate(withDuration: 0.2) {
        self.alpha = 1
      }
    }
  }
  
  func hideStoryBar() {
    if self.alpha == 1 {
      UIView.animate(withDuration: 0.2) {
        self.alpha = 0
      }
    }
  }
  
  func startAnimation() {
    layoutSubviews()
    animate()
  }
  
  func pause() {
    guard let barAnimation = barAnimation else { return }
    if barAnimation.isRunning {
      hideStoryBar()
      barAnimation.pauseAnimation()
    }
  }
  
  func resume() {
    guard let barAnimation = barAnimation else { return }
    if !barAnimation.isRunning {
      showStoryBar()
      barAnimation.startAnimation()
    }
  }
  
  func stop() {
    if let _ = barAnimation {
      barAnimation?.stopAnimation(true)
      if barAnimation?.state == .stopped {
        barAnimation?.finishAnimation(at: .current)
      }
    }
  }
  
  func animate(animationIndex: Int = 0) {
    let currentSegment = segments[animationIndex]
    currentAnimationIndex = animationIndex
    
    if let _ = barAnimation {
      barAnimation = nil
    }
    
    showStoryBar()
    barAnimation = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: {
      currentSegment.animatingBarView.frame.size.width = currentSegment.nonAnimatingBarView.frame.width
    })
    
    barAnimation?.addCompletion { [weak self] (position) in
      if position == .end {
        self?.next()
      }
    }
    
    barAnimation?.isUserInteractionEnabled = false
    barAnimation?.startAnimation()
  }
}

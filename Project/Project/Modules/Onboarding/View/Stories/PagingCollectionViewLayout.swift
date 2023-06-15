import UIKit

class PagingCollectionViewLayout: UICollectionViewFlowLayout {
  
  var velocityThresholdPerPage: CGFloat = 2
  var numberOfItemsPerPage: CGFloat = 1
  
  /// The `InvalidatedState` is used to represent what to invalidate
  /// in a collection view layout based on the invalidation context.
  var invalidationState: InvalidationState = .everything
  
  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    guard let collectionView = collectionView else { return proposedContentOffset }
    
    let pageLength: CGFloat
    let approxPage: CGFloat
    let currentPage: CGFloat
    let speed: CGFloat
    
    if scrollDirection == .horizontal {
      pageLength = (self.itemSize.width + self.minimumLineSpacing) * numberOfItemsPerPage
      approxPage = collectionView.contentOffset.x / pageLength
      speed = velocity.x
    } else {
      pageLength = (self.itemSize.height + self.minimumLineSpacing) * numberOfItemsPerPage
      approxPage = collectionView.contentOffset.y / pageLength
      speed = velocity.y
    }
    
    if speed < 0 {
      currentPage = ceil(approxPage)
    } else if speed > 0 {
      currentPage = floor(approxPage)
    } else {
      currentPage = round(approxPage)
    }
    
    guard speed != 0 else {
      if scrollDirection == .horizontal {
        return CGPoint(x: currentPage * pageLength, y: 0)
      } else {
        return CGPoint(x: 0, y: currentPage * pageLength)
      }
    }
    
    var nextPage: CGFloat = currentPage + (speed > 0 ? 1 : -1)
    
    let increment = speed / velocityThresholdPerPage
    nextPage += (speed < 0) ? ceil(increment) : floor(increment)
    
    if scrollDirection == .horizontal {
      return CGPoint(x: nextPage * pageLength, y: 0)
    } else {
      return CGPoint(x: 0, y: nextPage * pageLength)
    }
  }
  
  override func invalidateLayout() {
      super.invalidateLayout()
      invalidationState = .everything
    }
  
  open override func prepare() {
    super.prepare()
    
    switch invalidationState {
    case .everything:
      itemSize = UIScreen.main.bounds.size
    case .sizes:
      print(111)
    case .nothing:
      break
    }
      
    invalidationState = .nothing
  }
}

 class PagingInvalidationContext: UICollectionViewLayoutInvalidationContext {
  var invalidateSizes: Bool = false
}

 enum InvalidationState {
  case nothing
  case everything
  case sizes
  
   init(_ invalidationContext: UICollectionViewLayoutInvalidationContext) {
    if invalidationContext.invalidateEverything {
      self = .everything
    } else if invalidationContext.invalidateDataSourceCounts {
      self = .everything
    } else if let context = invalidationContext as? PagingInvalidationContext {
      if context.invalidateSizes {
        self = .sizes
      } else {
        self = .nothing
      }
    } else {
      self = .nothing
    }
  }
  
   static func +(lhs: InvalidationState, rhs: InvalidationState) -> InvalidationState {
    switch (lhs, rhs) {
    case (.everything, _), (_, .everything):
      return .everything
    case (.sizes, _), (_, .sizes):
      return .sizes
    case (.nothing, _), (_, .nothing):
      return .nothing
    default:
      return .everything
    }
  }
}


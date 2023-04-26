import Foundation

enum SortOrder {
  case ascending
  case descending
  
  func compare<T: Comparable>(_ lhs: T, _ rhs: T) -> ComparisonResult {
    switch self {
    case .ascending:
      return lhs < rhs ? .orderedAscending : (lhs > rhs ? .orderedDescending : .orderedSame)
    case .descending:
      return lhs > rhs ? .orderedAscending : (lhs < rhs ? .orderedDescending : .orderedSame)
    }
  }
}

protocol SortComparator {
  associatedtype Compared
  
  var order: SortOrder { get set }
  func compare(_ lhs: Self, _ rhs: Self) -> ComparisonResult
}

extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, order: SortOrder = .ascending) -> [Element] {
    return sorted { lhs, rhs in
      order.compare(lhs[keyPath: keyPath], rhs[keyPath: keyPath]) == .orderedAscending
    }
  }
}

extension Sequence where Element: SortComparator {
  func sorted() -> [Element] {
    return sorted { lhs, rhs in
      let result = lhs.compare(lhs, rhs)
      return result == .orderedAscending || (result == .orderedSame && lhs.order == .ascending)
    }
  }
}

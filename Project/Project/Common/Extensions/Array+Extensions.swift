import Foundation

extension Array where Element: Hashable {
  func excluding(_ elements: [Element]) -> [Element] {
    let set = Set(elements)
    return Array(Set(self).subtracting(set))
  }
}

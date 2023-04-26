import UIKit

struct RearrangeViewModel {
  let image: UIImage
  let pageNumber: String
  let deleteCompletion: ((RearrangeViewModel?) -> Void)
}

import UIKit

class AutoAddPaddingButtton: UIButton {
  override var intrinsicContentSize: CGSize {
    get {
      let baseSize = super.intrinsicContentSize
      return CGSize(width: baseSize.width + 20, height: baseSize.height)
    }
  }
}

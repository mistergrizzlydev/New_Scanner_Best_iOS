import UIKit

final class BorderLabel: UILabel {
  private let topInset: CGFloat = 4.0
  private let bottomInset: CGFloat = 4.0
  private let leftInset: CGFloat = 8.0
  private let rightInset: CGFloat = 8.0

  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    super.drawText(in: rect.inset(by: insets))
  }

  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(width: size.width + leftInset + rightInset,
                  height: size.height + topInset + bottomInset)
  }

  override var bounds: CGRect {
    didSet {
      // ensures this works within stack views if multi-line
      preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    layer.cornerRadius = 6.0
    clipsToBounds = true
    textColor = .labelTextColor
    backgroundColor = .labelColor.withAlphaComponent(0.32)
  }
}

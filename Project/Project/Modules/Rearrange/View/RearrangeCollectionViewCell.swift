import UIKit

final class RearrangeCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet private weak var pageNumberLabel: UILabel!
  @IBOutlet private weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var removeBtn: UIButton!
  
  private var isAnimate: Bool = false
  
  private var deleteCompletion: ((RearrangeViewModel?) -> Void)?
  private var viewModel: RearrangeViewModel?
  private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

  func configure(with viewModel: RearrangeViewModel) {
    self.viewModel = viewModel
    pageNumberLabel.text = viewModel.pageNumber
    thumbnailImageView.image = viewModel.image
    self.deleteCompletion = viewModel.deleteCompletion
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    pageNumberLabel.layer.cornerRadius = pageNumberLabel.frame.height/2
    pageNumberLabel.clipsToBounds = true
    
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 2)
    layer.shadowOpacity = 0.5
    layer.shadowRadius = 2
    layer.masksToBounds = false
  }
  
  //Animation of image
  func startAnimate() {
    let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
    shakeAnimation.duration = 0.05
    shakeAnimation.repeatCount = 4
    shakeAnimation.autoreverses = true
    shakeAnimation.duration = 0.2
    shakeAnimation.repeatCount = .infinity

    let startAngle: Float = (-2) * 3.14159/180
    let stopAngle = -startAngle

    shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
    shakeAnimation.toValue = NSNumber(value: 3 * stopAngle as Float)
    shakeAnimation.autoreverses = true
    shakeAnimation.timeOffset = 290 * drand48()

    let layer: CALayer = self.layer
    layer.add(shakeAnimation, forKey:"animate")
    removeBtn.isHidden = false
    isAnimate = true
    feedbackGenerator.impactOccurred()
  }

  func stopAnimate() {
    let layer: CALayer = self.layer
    layer.removeAnimation(forKey: "animate")
    self.removeBtn.isHidden = true
    isAnimate = false
  }

  @IBAction private func onDeleteTapped() {
    if isAnimate {
      deleteCompletion?(viewModel)
    }
  }
}

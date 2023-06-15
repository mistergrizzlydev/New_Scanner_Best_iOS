import UIKit

class Story2CollectionViewCell: UICollectionViewCell {
  
  @IBOutlet private weak var imageView: UIImageViewAligned!
  
  @IBOutlet private weak var featureLabel: UILabel!
  @IBOutlet private weak var featureImageView: UIImageView!
  
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var subtitleLabel: UILabel!
    
  @IBOutlet private weak var topConstraint: NSLayoutConstraint!
  
  override func awakeFromNib() {
    super.awakeFromNib()    
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.alignBottom = true
  }
  
  func setup(with story: StoryItem) {
    titleLabel.text = story.title
    subtitleLabel.text = story.subtitle
          
    imageView.image = story.image
    backgroundColor = story.bgColor
    
    featureLabel.text = story.storyFeature.name
    featureImageView.image = story.storyFeature.image
    
    titleLabel.textColor = story.textColor
    subtitleLabel.textColor = story.textColor
    featureLabel.textColor = story.textColor
    
    featureImageView.image = featureImageView.image?.tint(with: story.textColor)
  }
}

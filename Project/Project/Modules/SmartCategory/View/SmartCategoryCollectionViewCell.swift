import UIKit

final class SmartCategoryCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet private weak var containerImageView: UIView!
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var nameLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    containerImageView.layer.cornerRadius = 8
    containerImageView.clipsToBounds = true
    
    imageView.tintColor = .themeColor
  }
  
  func configure(with viewModel: SmartCategoryViewModel) {
    nameLabel.text = viewModel.category.name
    imageView.image = UIImage(systemName: viewModel.category.image)
    updateAppearance(based: viewModel.category == UserDefaults.getSmartCategory(name: viewModel.key) ?? UserDefaults.documentClasifierCategory)
  }

  private func updateAppearance(based isSelected: Bool) {
    if isSelected {
      containerImageView.layer.borderWidth = 2
      containerImageView.layer.borderColor = UIColor.themeSelectedColor.cgColor
      containerImageView.layer.shadowColor = UIColor.black.cgColor
      containerImageView.layer.shadowOpacity = 0.3
      containerImageView.layer.shadowRadius = 3
      containerImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
      
      imageView.tintColor = .themeSelectedColor
      nameLabel.textColor = .themeSelectedColor
    } else {
      containerImageView.layer.borderWidth = 0
      containerImageView.layer.borderColor = nil
      containerImageView.layer.shadowColor = nil
      containerImageView.layer.shadowOpacity = 0
      containerImageView.layer.shadowRadius = 0
      containerImageView.layer.shadowOffset = .zero
      
      imageView.tintColor = .themeColor
      nameLabel.textColor = .themeColor
    }
  }
}

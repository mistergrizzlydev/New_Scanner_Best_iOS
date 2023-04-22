import UIKit

final class ListTableViewCell: UITableViewCell {
  @IBOutlet private weak var folderImageView: UIImageView!
  @IBOutlet private weak var folderTitleLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func configure(with viewModel: ListViewModel) {
    folderImageView.image = viewModel.file.image
    folderTitleLabel.text = viewModel.file.name
  }
}

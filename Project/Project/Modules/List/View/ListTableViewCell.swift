import UIKit

final class ListTableViewCell: UITableViewCell {
  @IBOutlet private weak var folderImageView: UIImageView!
  @IBOutlet private weak var folderTitleLabel: UILabel!

  func configure(with viewModel: ListViewModel) {
    folderImageView.image = viewModel.file.image
    folderTitleLabel.text = viewModel.file.name
    
    let count = viewModel.file.count ?? 0
    accessoryType = count >= 1 ? .disclosureIndicator : .none
  }
}

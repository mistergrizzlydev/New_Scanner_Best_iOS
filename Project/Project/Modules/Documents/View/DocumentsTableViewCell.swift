import UIKit

final class DocumentsTableViewCell: UITableViewCell {
  
  @IBOutlet private weak var documentSubtitleLabel: UILabel!
  @IBOutlet private weak var documentTitleLabel: UILabel!
  
  @IBOutlet private weak var fileImageView: UIImageView!
  @IBOutlet private weak var folderImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    tintAdjustmentMode = .normal
    tintColor = UIColor.themeColor
  }

  func configure(with viewModel: DocumentsViewModel) {
    fileImageView.image = nil
    folderImageView.image = nil
    
    documentTitleLabel.text = viewModel.file.name
    
    if let count = viewModel.file.count, let date = viewModel.file.date, let sizeOfFile = viewModel.file.sizeOfFile {
      let countTitle = viewModel.file.type == .file ? "Pages" : "Files"
      documentSubtitleLabel.text = "\(sizeOfFile), \(count) \(countTitle)\n\(date)"
    }
    
    switch viewModel.file.type {
    case .file:
      folderImageView.image = .file
      fileImageView.image = viewModel.file.image
    case .folder:
      folderImageView.image = viewModel.file.image
    }
  }
}

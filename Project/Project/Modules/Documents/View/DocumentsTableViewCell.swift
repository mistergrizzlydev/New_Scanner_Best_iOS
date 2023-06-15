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

  func configure(with viewModel: DocumentsViewModel, searchText: String) {
    fileImageView.image = nil
    folderImageView.image = nil
    
    let viewModelTitle = viewModel.file.name
    let attributedString = NSMutableAttributedString(string: viewModelTitle)
    let highlightColor = UIColor.yellow
    let range = (viewModelTitle as NSString).range(of: searchText, options: .caseInsensitive)
    attributedString.addAttribute(.backgroundColor, value: highlightColor, range: range)
    documentTitleLabel.attributedText = attributedString
    
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

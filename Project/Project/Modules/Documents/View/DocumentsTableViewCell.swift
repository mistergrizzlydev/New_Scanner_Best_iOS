//
//  DocumentsTableViewCell.swift
//  Project
//
//  Created by Mister Grizzly on 06.04.2023.
//

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
    
//    let view = UIView()
//    view.backgroundColor = .red
//    editingAccessoryView = view
    
//    if let editControl = editingAccessoryView as? UIControl {
//            editControl.backgroundColor = UIColor.red
//        }
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
    
//    (subviews.first as? UIView)?.backgroundColor = .red
    
//    subviews[1].subviews.first?.subviews.first?.subviews.first?.backgroundColor = .red
//    if selected {
//      
//      subviews.last?.subviews.first?.tintColor = .red
//      
//      subviews.last?.backgroundColor = .blue
//      subviews.last?.layer.cornerRadius = 25.6667/2
//      subviews.last?.clipsToBounds = true
//      
//      if let imageView = subviews.last?.subviews.first as? UIImageView {
//        imageView.image = UIImage(systemName: "checkmark.circle.fill")
//      }
//    }
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

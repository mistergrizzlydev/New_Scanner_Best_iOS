import UIKit

struct Folder: Document {
  var url: URL
  
  var thumbnailURL: URL?
  var image: UIImage?
  
  init(url: URL) {
    self.url = url
    
    if let count = count, count > 0 {
      image = .fullFolder
    } else {
      image = .emptyFolder
    }
  }
}

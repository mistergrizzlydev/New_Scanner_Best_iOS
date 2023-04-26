import UIKit

struct File: Document {
  init(url: URL) {
    self.url = url
  }
  
  var thumbnailURL: URL?
  var image: UIImage?
  var url: URL

  init(url: URL, image: UIImage?, thumbnailURL: URL?) {
    self.url = url
    self.image = image
    self.thumbnailURL = thumbnailURL
  }
}

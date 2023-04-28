import Photos
import PhotosUI

extension Array where Element == PHPickerResult {
  typealias ResultHandler = ([UIImage]?, Error?) -> Void
  
  func loadImages(completion: @escaping ResultHandler) {
    var images = [UIImage]()
    let dispatchGroup = DispatchGroup()
    
    for result in self {
      if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
        dispatchGroup.enter()
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
          if let error = error {
            debugPrint("Error loading image: \(error.localizedDescription)")
          } else if let image = image as? UIImage {
            images.append(image)
          }
          
          dispatchGroup.leave()
        }
      }
    }
    
    dispatchGroup.notify(queue: .main) {
      completion(images, nil)
    }
  }
}

import Foundation
import UIKit

public class SandwichPDF {
  public static func transform(key: String, image: UIImage,
                               toSandwichPDFatURL url: URL,
                               completion: @escaping (_ error: Bool) -> Void) {
    guard isValid(key: key) else {
      completion(false)
      return
    }
    PDFSandwichMaker.transform(image: image, toSandwichPDFatURL: url, completion: completion)
  }
  
  public static func transform(key: String, images: [UIImage],
                               toSandwichPDFatURL url: URL,
                               isTextRecognition: Bool = true,
                               quality: CompressionLevel = .medium,
                               fontColor: UIColor = .clear,
                               completion: @escaping (_ error: Bool) -> Void) {
    
    guard isValid(key: key) else {
      completion(false)
      return
    }
    
    PDFSandwichMaker.transform(images: images,
                               toSandwichPDFatURL: url,
                               isTextRecognition: isTextRecognition,
                               quality: quality,
                               fontColor: fontColor,
                               completion: completion)
    
  }
  
  static func isValid(key: String) -> Bool {
    let personalKey = "K6THam-YqqTcU-WTWSde-qaayNa-cDqMLc-gLH"
    return key == personalKey
  }
}

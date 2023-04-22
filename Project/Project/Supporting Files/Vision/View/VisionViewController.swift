import UIKit
import Vision
import PDFKit
import Sandwich

protocol VisionViewControllerProtocol: AnyObject {
  func prepare(with viewModel: VisionViewModel)
}

enum VisionDocumentType: Int, CaseIterable {
  case document = 0
  case text = 1
  
  var title: String {
    switch self {
    case .document: return "Document"
    case .text: return "Text"
    }
  }
}


final class VisionViewController: UIViewController, VisionViewControllerProtocol {
  var presenter: VisionPresenterProtocol!
  
  @IBOutlet private weak var pdfView: PDFView!
  @IBOutlet private weak var textView: UITextView!
  
  private var visionViewType: VisionDocumentType = .document
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }
  
  private func setupViews() {
    // Set up the image view
    
    pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    pdfView.displayMode = .singlePage
    pdfView.displayDirection = .horizontal
    pdfView.autoScales = true
    pdfView.usePageViewController(true, withViewOptions: [:])
    
    pdfView.subviews.forEach { subview in
      if let scrollView = subview.subviews.first as? UIScrollView {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
      }
    }
    
    // Create a segmented control
    let segmentControl = UISegmentedControl(items: VisionDocumentType.allCases.map { $0.title })
    segmentControl.selectedSegmentIndex = visionViewType.rawValue
    segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    
    // Set the segmented control as the title view of the tab bar item
    navigationItem.titleView = segmentControl
    
    modelUI(visionViewType)
  }
  
  func prepare(with viewModel: VisionViewModel) {
    if let pdfDocument = PDFDocument(url: viewModel.url) {
      pdfView.document = pdfDocument
      let personalKey = "K6THam-YqqTcU-WTWSde-qaayNa-cDqMLc-gLH"
      
      let images = [UIImage(named: "invoice1")!.withGrayLayer()!, UIImage(named: "invoice2")!.withGrayLayer()!]
     
      
      
      let tmpDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
      let fileURL = tmpDirectoryURL.appendingPathComponent("sandwich.pdf")
      
      SandwichPDF.transform(key: personalKey, images: images, toSandwichPDFatURL: fileURL) { error in
        print(error, fileURL)
      }
    }
  }
  
  @objc private func segmentChanged(_ sender: UISegmentedControl) {
    if let visionViewType = VisionDocumentType(rawValue: sender.selectedSegmentIndex) {
      modelUI(visionViewType)
      self.visionViewType = visionViewType
    }
  }
  
  private func modelUI(_ visionViewType: VisionDocumentType) {
    switch visionViewType {
    case .document:
      pdfView.isHidden = false
      textView.isHidden = true
      displayDocument()
    case .text:
      textView.isHidden = false
      pdfView.isHidden = true
      displayText()
    }
  }
  
  private func displayDocument() {
    
  }
  
  private func displayText() {
    
  }
}




/*
 
 private func recognizeText(image: UIImage) throws {
   guard let ciImage = CIImage(image: image) else {
     throw RecognitionError.unableToCreateCIImage
   }
   
   let request = VNRecognizeTextRequest(completionHandler: { (request, error) in
     do {
       guard error == nil else {
         throw RecognitionError.recognitionFailed(error!)
       }
       
       guard let results = request.results as? [VNRecognizedTextObservation] else {
         throw RecognitionError.unableToGetRecognizedText
       }
       
       for result in results {
         guard let bestCandidate = result.topCandidates(1).first else {
           continue
         }
         
         print(bestCandidate.string)
       }
     } catch {
       print("Error in VNRecognizeTextRequest completionHandler: \(error)")
     }
   })
   
   request.recognitionLevel = .accurate
   request.usesLanguageCorrection = true
   
   let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
   
   do {
     try handler.perform([request])
   } catch {
     throw RecognitionError.unableToPerformRequest(error)
   }
 }
 
 enum RecognitionError: Error {
   case unableToCreateCIImage
   case unableToGetRecognizedText
   case recognitionFailed(Error)
   case unableToPerformRequest(Error)
 }

 
 
 func recognizeText(in images: [UIImage], completion: @escaping (Result<[String], RecognitionError>) -> Void) {
     var recognizedTexts: [String] = []
     var errors: [RecognitionError] = []
     
     let dispatchGroup = DispatchGroup()
     
     for image in images {
         guard let ciImage = CIImage(image: image) else {
             errors.append(.unableToCreateCIImage)
             continue
         }
         
         dispatchGroup.enter()
         
         let request = VNRecognizeTextRequest(completionHandler: { (request, error) in
             defer {
                 dispatchGroup.leave()
             }
             
             do {
                 guard error == nil else {
                     throw RecognitionError.recognitionFailed(error!)
                 }
                 
                 guard let results = request.results as? [VNRecognizedTextObservation] else {
                     throw RecognitionError.unableToGetRecognizedText
                 }
                 
                 var recognizedText = ""
                 for result in results {
                     guard let bestCandidate = result.topCandidates(1).first else {
                         continue
                     }
                     
                     recognizedText += "\(bestCandidate.string) "
                 }
                 
                 recognizedTexts.append(recognizedText)
             } catch let error as RecognitionError {
                 errors.append(error)
             } catch {
//                  errors.append(.unknownError(error))
             }
         })
         
         request.recognitionLevel = .accurate
         request.usesLanguageCorrection = true
         
         let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
         
       do {
         try handler.perform([request])
       } catch {
         
       }
     }
     
     dispatchGroup.notify(queue: .main) {
         if !errors.isEmpty {
             completion(.failure(errors.first!))
         } else {
             completion(.success(recognizedTexts))
         }
     }
 }

//  // Example usage:
//  let images = [UIImage(named: "image1")!, UIImage(named: "image2")!, UIImage(named: "image3")!]
//  recognizeText(in: images) { result in
//      switch result {
//      case .success(let recognizedTexts):
//          let resultText = recognizedTexts.joined(separator: "\n")
//          textView.text = resultText
//      case

 
 
 
 
 
 
 
 
 
//  func recognizeText(in images: [UIImage]) throws -> [String] {
//      var recognizedTexts: [String] = []
//
//      for image in images {
//          guard let ciImage = CIImage(image: image) else {
//              throw RecognitionError.unableToCreateCIImage
//          }
//
//          let request = VNRecognizeTextRequest(completionHandler: { (request, error) in
//              do {
//                  guard error == nil else {
//                      throw RecognitionError.recognitionFailed(error!)
//                  }
//
//                  guard let results = request.results as? [VNRecognizedTextObservation] else {
//                      throw RecognitionError.unableToGetRecognizedText
//                  }
//
//                  var recognizedText = ""
//                  for result in results {
//                      guard let bestCandidate = result.topCandidates(1).first else {
//                          continue
//                      }
//
//                      recognizedText += "\(bestCandidate.string) "
//                  }
//
////                  recognizedTexts.append(recognizedText.trimmingCharacters(in: .whitespacesAndNewlines))
//                recognizedTexts.append(recognizedText)
//              } catch {
//                  print("Error in VNRecognizeTextRequest completionHandler: \(error)")
//              }
//          })
//
//          request.recognitionLevel = .accurate
//          request.usesLanguageCorrection = true
//
//          let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
//
//          do {
//              try handler.perform([request])
//          } catch {
//              throw RecognitionError.unableToPerformRequest(error)
//          }
//      }
//
//      return recognizedTexts
//  }

 // Example usage:
//  let images = [UIImage(named: "image1")!, UIImage(named: "image2")!, UIImage(named: "image3")!]
//  let recognizedTexts = try recognizeText(in: images)
//  let resultText = recognizedTexts.joined(separator: "\n")
//  textView.text = resultText

 
 
 
 
 
   
   
   //  private func recognizeText(image: UIImage) {
   //    guard let ciImage = CIImage(image: image) else {
   //        fatalError("Unable to create CIImage from UIImage")
   //    }
   //
   //    let request = VNRecognizeTextRequest(completionHandler: { (request, error) in
   //        guard let results = request.results as? [VNRecognizedTextObservation] else {
   //            fatalError("Unable to get recognized text")
   //        }
   //
   //        for result in results {
   //            guard let bestCandidate = result.topCandidates(1).first else {
   //                continue
   //            }
   //
   //            print(bestCandidate.string)
   //        }
   //    })
   //
   //    request.recognitionLevel = .accurate
   //    request.usesLanguageCorrection = true
   //
   //    let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
   //
   //    do {
   //        try handler.perform([request])
   //    } catch {
   //        print(error)
   //    }
   
   

 
 @objc private func segmentChanged(_ sender: UISegmentedControl) {
   if let visionViewType = VisionDocumentType(rawValue: sender.selectedSegmentIndex) {
     modelUI(visionViewType)
     self.visionViewType = visionViewType
   }
 }
 
 private func modelUI(_ visionViewType: VisionDocumentType) {
   switch visionViewType {
   case .document:
     pdfView.isHidden = false
     textView.isHidden = true
     displayDocument()
   case .text:
     textView.isHidden = false
     pdfView.isHidden = true
     displayText()
   }
 }
 
 private func displayDocument() {
   
 }
 
 private func displayText() {
   
 }
}

extension PDFDocument {
 func extractA4Images() -> [UIImage] {
   var images = [UIImage]()
   for pageNumber in 0..<self.pageCount {
     guard let page = self.page(at: pageNumber) else {
       continue
     }
     
     let imageRect = page.bounds(for: .mediaBox)
     let image = UIImage(cgImage: page.thumbnail(of: CGSize(width: imageRect.width, height: imageRect.height),
                                                 for: .mediaBox).cgImage!)
     images.append(image)
     print(image.size, image.scale)
   }
   
   return images
 }
}
 
extension PDFDocument {
 func extractScaleDividedTTImages() -> [UIImage] {
   var images = [UIImage]()
   for pageNumber in 0..<self.pageCount {
     guard let page = self.page(at: pageNumber) else {
       continue
     }
     let mediaBoxRect = page.bounds(for: .mediaBox)
     let scale = UIScreen.main.scale / 2
     
     UIGraphicsBeginImageContextWithOptions(CGSize(width: mediaBoxRect.size.width * scale,
                                                   height: mediaBoxRect.size.height * scale),
                                            false, scale)
     
     guard let context = UIGraphicsGetCurrentContext() else {
       continue
     }
     
     context.saveGState()
     
     context.translateBy(x: 0, y: mediaBoxRect.size.height * scale)
     context.scaleBy(x: 1.0, y: -1.0)
     
     page.draw(with: .mediaBox, to: context)
     
     guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
       continue
     }
     
     context.restoreGState()
     
     UIGraphicsEndImageContext()
     print(image.size, image.scale)
     images.append(image)
   }
   
   return images
 }
}

//import UIKit
//import Vision
//
//class PDFTextRecognitionManager {
//
//    private let queue = DispatchQueue(label: "PDFTextRecognitionManagerQueue", qos: .userInitiated)
//
//    func recognizeText(in images: [UIImage], completion: @escaping (String) -> Void) {
//
//        var index = 0
//
//        let requestHandler = VNImageRequestHandler()
//
//        let request = VNRecognizeTextRequest { (request, error) in
//            if let error = error {
//                print("Error recognizing text: \(error.localizedDescription)")
//            }
//            if let results = request.results as? [VNRecognizedTextObservation], let firstResult = results.first {
//                let recognizedText = firstResult.topCandidates(1).first?.string ?? ""
//                completion(recognizedText)
//            }
//            index += 1
//            if index < images.count {
//                self.recognizeText(in: [images[index]], completion: completion)
//            }
//        }
//
//        request.recognitionLevel = .accurate
//        request.usesLanguageCorrection = true
//
//        queue.async {
//            do {
//                for image in images {
//                    guard let cgImage = image.cgImage else {
//                        continue
//                    }
//                    let orientation = CGImagePropertyOrientation(image.imageOrientation)
//                    let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
//                    try imageRequestHandler.perform([request])
//                }
//            } catch {
//                print("Error performing text recognition: \(error.localizedDescription)")
//            }
//        }
//    }
//}

class ImageTextRecognitionQueue: Operation {
   private let images: [UIImage]
   private let completion: ([String]) -> Void
   
   init(images: [UIImage], completion: @escaping ([String]) -> Void) {
       self.images = images
       self.completion = completion
       super.init()
   }
   
   override func main() {
       let textRecognized = NSMutableArray()
       let group = DispatchGroup()
       
       for image in images {
           group.enter()
           let recognitionRequest = VNRecognizeTextRequest { request, error in
               if let error = error {
                   print("Error recognizing text: \(error.localizedDescription)")
               } else {
                   guard let observations = request.results as? [VNRecognizedTextObservation] else {
                       return
                   }
                   let recognizedText = observations.compactMap { observation in
                       observation.topCandidates(1).first?.string
                   }.joined(separator: " ")
                   
                   textRecognized.add(recognizedText)
                   group.leave()
               }
           }
           recognitionRequest.recognitionLevel = .accurate
           recognitionRequest.usesLanguageCorrection = true
           
           let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
           do {
               try requestHandler.perform([recognitionRequest])
           } catch {
               print("Error performing recognition request: \(error.localizedDescription)")
           }
       }
       
       group.notify(queue: DispatchQueue.main) {
           let result = textRecognized.compactMap { $0 as? String }
           self.completion(result)
       }
   }
}

/////
///
///
///
//class RecognizeTextOperation: Operation {
//
//    var images: [UIImage]
//    var results: [String] = []
//
//    init(images: [UIImage]) {
//        self.images = images
//    }
//
//    override func main() {
//        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//
//        for image in images {
//            let operation = TextRecognitionOperation(image: image)
//            operation.completionBlock = {
//                if let result = operation.result {
//                    self.results.append(result)
//                }
//            }
//            queue.addOperation(operation)
//        }
//
//        queue.waitUntilAllOperationsAreFinished()
//    }
//}
//
//class TextRecognitionOperation: Operation {
//    var result: String?
//
//    private let image: UIImage
//
//    init(image: UIImage) {
//        self.image = image
//        super.init()
//    }
//
//    override func main() {
//        let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
//            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
//                return
//            }
//
//            let recognizedStrings = observations.compactMap { observation in
//                observation.topCandidates(1).first?.string
//            }
//
//            if let recognizedString = recognizedStrings.first {
//                self.result = recognizedString
//            }
//        }
//
//        let requestHandler = VNImageRequestHandler(cgImage: self.image.cgImage!, options: [:])
//        do {
//            try requestHandler.perform([textRecognitionRequest])
//        } catch {
//            print(error)
//        }
//    }
//}


//import UIKit
//import Vision
//
//class TextRecognitionOperation: Operation {
//
//    var images: [UIImage]
//    var recognizedTexts: [String]
//
//    init(images: [UIImage]) {
//        self.images = images
//        self.recognizedTexts = []
//    }
//
//    override func main() {
//        let textRecognitionRequest = VNRecognizeTextRequest()
//        textRecognitionRequest.recognitionLevel = .accurate
//        textRecognitionRequest.usesLanguageCorrection = true
//
//        let textRecognitionWorkQueue = DispatchQueue(label: "textRecognitionQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
//
//        for (index, image) in images.enumerated() {
//            guard let cgImage = image.cgImage else {
//                continue
//            }
//
//            let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//
//            textRecognitionWorkQueue.async {
//                do {
//                    try imageRequestHandler.perform([textRecognitionRequest])
//
//                    guard let observations = textRecognitionRequest.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
//                        return
//                    }
//
//                    var recognizedText = ""
//                    for observation in observations {
//                        guard let topCandidate = observation.topCandidates(1).first else { continue }
//                        recognizedText += topCandidate.string + " "
//                    }
//                    self.recognizedTexts.append(recognizedText)
//                    print("Text recognition complete for image \(index)")
//                } catch {
//                    print("Error recognizing text in image \(index): \(error)")
//                }
//            }
//        }
//    }
//}

/*
let images = [UIImage(named: "image1.jpg")!, UIImage(named: "image2.jpg")!, UIImage(named: "image3.jpg")!]

let recognizeOperation = RecognizeTextOperation(images: images)
recognizeOperation.completionBlock = {
    if recognizeOperation.results.count == images.count {
        print(recognizeOperation.results) // This will print an array of recognized strings, one for each image
    }
}

let queue = OperationQueue()
queue.addOperation(recognizeOperation)

*/
class RecognizeTextOperation: Operation {
   
   var images: [UIImage]
   var results: [String] = []
   
   init(images: [UIImage]) {
       self.images = images
   }
   
   override func main() {
       let queue = OperationQueue()
       queue.maxConcurrentOperationCount = 1
       
       for image in images {
           let operation = TextRecognitionOperation(image: image)
           operation.completionBlock = {
               if let result = operation.result {
                   self.results.append(result)
               }
           }
           queue.addOperation(operation)
       }
       
       queue.waitUntilAllOperationsAreFinished()
   }
}

class TextRecognitionOperation: Operation {
   var result: String?
   
   private let image: UIImage
   
   init(image: UIImage) {
       self.image = image
       super.init()
   }
   
   override func main() {
       let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
           guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
               return
           }
           
           var recognizedStrings = ""
           for observation in observations {
               guard let topCandidate = observation.topCandidates(1).first else {
                   continue
               }
               recognizedStrings += "\(topCandidate.string) "
           }
           
           if !recognizedStrings.isEmpty {
               self.result = recognizedStrings
           }
       }
       
       let requestHandler = VNImageRequestHandler(cgImage: self.image.cgImage!, options: [:])
       do {
           try requestHandler.perform([textRecognitionRequest])
       } catch {
           print(error)
       }
   }
}


//// / /// ///
///
///
class RecognizeTextOperation2: Operation {
   
   var images: [UIImage]
   var results: [NSAttributedString] = []
   
   init(images: [UIImage]) {
       self.images = images
   }
   
   override func main() {
       let queue = OperationQueue()
       queue.maxConcurrentOperationCount = 1
       
       for image in images {
           let operation = TextRecognitionOperation2(image: image)
           operation.completionBlock = {
               if let result = operation.result {
                 self.results.append(contentsOf: result)
               }
           }
           queue.addOperation(operation)
       }
       
       queue.waitUntilAllOperationsAreFinished()
   }
}

//class TextRecognitionOperation2: Operation {
//    var result: NSAttributedString?
//
//    private let image: UIImage
//
//    init(image: UIImage) {
//        self.image = image
//        super.init()
//    }
//
//    override func main() {
//        let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
//            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
//                return
//            }
//
//            let attributedString = NSMutableAttributedString()
//
//            for observation in observations {
//                let recognizedStrings = observation.topCandidates(1).map { $0.string }
//                let text = recognizedStrings.joined(separator: " ")
//                let font = UIFont.systemFont(ofSize: observation.boundingBox.height * image.size.height)
//
//                let attributes: [NSAttributedString.Key: Any] = [
//                    .font: font,
//                    .foregroundColor: UIColor.black,
//                    .backgroundColor: UIColor.clear,
//                ]
//
//                let attributedSubstring = NSAttributedString(string: text, attributes: attributes)
//
//                // Get the bounding box of the text and add it as a custom attribute to the attributed string.
//                let x = observation.boundingBox.origin.x * self.image.size.width
//                let y = (1 - observation.boundingBox.origin.y) * self.image.size.height - observation.boundingBox.height * self.image.size.height
//                let width = observation.boundingBox.width * self.image.size.width
//                let height = observation.boundingBox.height * self.image.size.height
//
//                let boundingRect = CGRect(x: x, y: y, width: width, height: height)
//                attributedSubstring.addAttribute(.boundingRect, value: NSValue(cgRect: boundingRect), range: NSRange(location: 0, length: attributedSubstring.length))
//
//                attributedString.append(attributedSubstring)
//            }
//
//            self.result = attributedString
//        }
//
//        let requestHandler = VNImageRequestHandler(cgImage: self.image.cgImage!, options: [:])
//        do {
//            try requestHandler.perform([textRecognitionRequest])
//        } catch {
//            print(error)
//        }
//    }
//}

class TextRecognitionOperation2: Operation {
   var result: [NSAttributedString]?
   
   private let image: UIImage
   
   init(image: UIImage) {
       self.image = image
       super.init()
   }
   
   override func main() {
       let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
           guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
               return
           }
           
           let attributedStrings = observations.compactMap { observation in
               let attributedString = NSMutableAttributedString()
               let recognizedStrings = observation.topCandidates(1).compactMap { $0.string }
               
               let imageSize = self.image.size
               
               for recognizedString in recognizedStrings {
//                    let textString = recognizedString.trimmingCharacters(in: .whitespacesAndNewlines)
//                    let textRect = observation.boundingBox(for: observation.boundingBox).scaled(to: imageSize)
                   
                   let attributes: [NSAttributedString.Key: Any] = [
                       .font: UIFont.systemFont(ofSize: 20),
                       .foregroundColor: UIColor.white,
                       NSAttributedString.Key(rawValue: TextBoundingRectAttribute.name): NSValue(cgRect: observation.boundingBox)
                   ]
                   
                   let attributedSubstring = NSAttributedString(string: recognizedString, attributes: attributes)
                   attributedString.append(attributedSubstring)
               }
               
               return attributedString
           }
           
           self.result = attributedStrings
       }
       
       let requestHandler = VNImageRequestHandler(cgImage: self.image.cgImage!, options: [:])
       do {
           try requestHandler.perform([textRecognitionRequest])
       } catch {
           print(error)
       }
   }
}

struct TextBoundingRectAttribute {
   static let name = "TextBoundingRectAttribute"
}

extension NSAttributedString {
   func textBoundingRects() -> [CGRect] {
       var textBoundingRects: [CGRect] = []
     enumerateAttribute(NSAttributedString.Key(rawValue: TextBoundingRectAttribute.name), in: NSRange(location: 0, length: length), options: []) { (value, range, _) in
           if let rectValue = value as? NSValue {
               textBoundingRects.append(rectValue.cgRectValue)
           }
       }
       return textBoundingRects
   }
}

extension UIImage {
   func
       imageByMakingWhiteBackgroundTransparent() -> UIImage?
   {

       let image = UIImage(data: self.jpegData(compressionQuality: 1.0)!)!
       let rawImageRef: CGImage = image.cgImage!

       let maskingFrom: CGFloat = 88
       let maskingTo: CGFloat = 255
       let colorMasking: [CGFloat] = [
           maskingFrom, maskingTo,
           maskingFrom, maskingTo,
           maskingFrom, maskingTo,
       ]
       UIGraphicsBeginImageContext(image.size)

       let maskedImageRef = rawImageRef.copy(maskingColorComponents: colorMasking)
       UIGraphicsGetCurrentContext()?.translateBy(x: 0.0, y: image.size.height)
       UIGraphicsGetCurrentContext()?.scaleBy(x: 1.0, y: -1.0)
       UIGraphicsGetCurrentContext()?.draw(
           maskedImageRef!,
           in: CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height)
       )
       let result = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       return result

   }

}

 */

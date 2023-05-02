import CoreML
import Vision
import UIKit

public enum DocumentClassifierMLResult {
  case receipt(confidence: Double)
  case invoice(confidence: Double)
  case form(confidence: Double)
  case letter(confidence: Double)
  
  case id(confidence: Double)
  case businessCard(confidence: Double)
  case news(confidence: Double)
  case music(confidence: Double)

  case handwritten(confidence: Double)
  case unknown(confidence: Double)
  
  public init?(classificationObservation: VNClassificationObservation) {
    switch classificationObservation.identifier.lowercased() {
    case "invoice", "invoice or bill".lowercased():
      self = .invoice(confidence: Double(classificationObservation.confidence))
    case "receipt".lowercased():
      self = .receipt(confidence: Double(classificationObservation.confidence))
    case "music", "music sheet".lowercased():
      self = .music(confidence: Double(classificationObservation.confidence))
    case "id".lowercased():
      self = .id(confidence: Double(classificationObservation.confidence))
    case "HandWritten".lowercased(), "Note".lowercased(), "Paper note".lowercased():
      self = .handwritten(confidence: Double(classificationObservation.confidence))
    case "Form".lowercased():
      self = .form(confidence: Double(classificationObservation.confidence))
    case "News".lowercased(), "Book or Magazine".lowercased(): // books or magazine comes here
      self = .news(confidence: Double(classificationObservation.confidence))
    case "Unknown".lowercased():
      self = .unknown(confidence: Double(classificationObservation.confidence))
    case "Letter".lowercased():
      self = .letter(confidence: Double(classificationObservation.confidence))
    case "Business Card".lowercased():
      self = .businessCard(confidence: Double(classificationObservation.confidence))
    default:
      return nil
    }
  }
  
  public var intValue: Int {
    switch self {
    case .receipt(_):
      return 0
    case .invoice(_):
      return 1
    case .form(_):
      return 2
    case .letter(_):
      return 3
    case .id(_):
      return 4
    case .businessCard(_):
      return 5
    case .news(_):
      return 6
    case .music(_):
      return 7
    case .handwritten(_):
      return 8
    case .unknown(_):
      return 9
    }
  }
  
  public init?(tag: Int) {
    switch tag {
    case 0:
      self = .receipt(confidence: 100)
    case 1:
      self = .invoice(confidence: 100)
    case 2:
      self = .form(confidence: 100)
    case 3:
      self = .letter(confidence: 100)
    case 4:
      self = .id(confidence: 100)
    case 5:
      self = .businessCard(confidence: 100)
    case 6:
      self = .news(confidence: 100)
    case 7:
      self = .music(confidence: 100)
    case 8:
      self = .handwritten(confidence: 100)
    case 9:
      self = .unknown(confidence: 100)
    default:
      return nil
    }
  }
  
  public var allCases: [DocumentClassifierMLResult] {
    [.receipt(confidence: 0), .invoice(confidence: 0), .form(confidence: 0), .letter(confidence: 0),
     .id(confidence: 0), .businessCard(confidence: 0), .news(confidence: 0), .music(confidence: 0),
     .handwritten(confidence: 0), .unknown(confidence: 0.99)]
  }
  
  public var name: String {
    switch self {
    case .receipt(_):
      return "Receipt"
    case .invoice(_):
      return "Invoice or Bill"
    case .form(_):
      return "Form"
    case .letter(_):
      return "Letter"
    case .id(_):
      return "ID"
    case .businessCard(_):
      return "Business Card"
    case .news(_):
      return "Book or Magazine"
    case .music(_):
      return "Music Sheet"
    case .handwritten(_):
      return "Letter"
    case .unknown(_):
      return "Other"
    }
  }
}

class DocumentClassifier {
  static func check(with image: UIImage, completion: @escaping (DocumentClassifierMLResult?, Error?) -> Void) {
    // Load the model
    guard let modelURL = Bundle(for: DocumentClassifier.self).url(forResource: "doc_classifier_v5_fp16", withExtension: "mlmodelc") else {
            //Bundle.main.url(forResource: "doc_classifier_v5_fp16", withExtension: "mlmodelc") else {
      return completion(nil, "Failed to load the model".toError)
    }
    guard let model = try? VNCoreMLModel(for: MLModel(contentsOf: modelURL)) else {
      return completion(nil, "Failed to create a Vision model".toError)
    }
    
    // Prepare the image for classification
    let ciImage = CIImage(image: image)!
    let handler = VNImageRequestHandler(ciImage: ciImage)
    
    // Perform the classification
    let request = VNCoreMLRequest(model: model) { request, error in
      guard let observations = request.results as? [VNClassificationObservation] else {
        return completion(nil, "Unexpected result type from the Core ML model".toError)
      }
      // Get the top prediction
      guard let topPrediction = observations.first else {
        return completion(nil, "Failed to get a prediction from the Core ML model".toError)
      }
      // Print the predicted class label and probability score
      print("Class label: \(topPrediction.identifier), probability: \(topPrediction.confidence)")
      
      completion(DocumentClassifierMLResult(classificationObservation: topPrediction), nil)
    }
    do {
      try handler.perform([request])
    } catch {
      fatalError("Failed to perform the Core ML request: \(error)")
    }
  }
}


private extension String {
    var toError: Error {
        return NSError(domain: "technical error", code: 0, userInfo: [NSLocalizedDescriptionKey: self])
    }
}

//class DocClassifierV2 {
//  static func check(with image: UIImage) {
//    // Load the model
//    guard let modelURL = Bundle.main.url(forResource: "doc_classifier_v5_fp16", withExtension: "mlmodelc") else {
//        fatalError("Failed to load the model")
//    }
//    guard let model = try? VNCoreMLModel(for: MLModel(contentsOf: modelURL)) else {
//        fatalError("Failed to create a Vision model")
//    }
//
//    // Prepare the image for classification
//    let ciImage = CIImage(image: image)!
//    let handler = VNImageRequestHandler(ciImage: ciImage)
//
//    // Perform the classification
//    let request = VNCoreMLRequest(model: model) { request, error in
//        guard let observations = request.results as? [VNClassificationObservation] else {
//            fatalError("Unexpected result type from the Core ML model")
//        }
//        // Get the top prediction
//        guard let topPrediction = observations.first else {
//            fatalError("Failed to get a prediction from the Core ML model")
//        }
//        // Print the predicted class label and probability score
//        print("Class label: \(topPrediction.identifier), probability: \(topPrediction.confidence)")
//    }
//    do {
//        try handler.perform([request])
//    } catch {
//        fatalError("Failed to perform the Core ML request: \(error)")
//    }
//  }
//}

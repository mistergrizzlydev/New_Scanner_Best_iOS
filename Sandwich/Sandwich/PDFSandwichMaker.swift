import UIKit
import PDFKit
import Vision

final class PDFSandwichMaker {
  // copied from https://github.com/De30/ios_nextcloud/blob/23c9131b2906c8e864e616d5169228b689c698c5/iOSClient/Scan%20document/NCUploadScanDocument.swift
  
  static func transform(image: UIImage, toSandwichPDFatURL url: URL, completion: @escaping (_ error: Bool) -> Void) {
    DispatchQueue.global().async {
      let pdfData = NSMutableData()
      
      UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
      
      drawImage(image: image, quality: 0, isTextRecognition: true, fontColor: UIColor.clear)
      
      UIGraphicsEndPDFContext()
      
      do {
        try pdfData.write(to: url, options: .atomic)
      } catch {
        print("Error: \(error)")
      }
      
      DispatchQueue.main.async { completion(false) }
    }
  }
  
  private static func drawImage(image: UIImage, quality: Double, isTextRecognition: Bool, fontColor: UIColor) {
    let image = changeCompressionImage(image, quality: quality)
    let bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
    
    if isTextRecognition {
      
      UIGraphicsBeginPDFPageWithInfo(bounds, nil)
      image.draw(in: bounds)
      
      let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
      
      let textRecognitionRequest = VNRecognizeTextRequest { request, _ in
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        for observation in observations {
          guard let textLine = observation.topCandidates(1).first else { continue }
          
          var t: CGAffineTransform = CGAffineTransform.identity
          t = t.scaledBy(x: image.size.width, y: -image.size.height)
          t = t.translatedBy(x: 0, y: -1)
          let rect = observation.boundingBox.applying(t)
          let text = textLine.string
          
          let font = UIFont.systemFont(ofSize: rect.size.height, weight: .regular)
          let attributes = bestFittingFont(for: text, in: rect, fontDescriptor: font.fontDescriptor, fontColor: fontColor)
          
          text.draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        }
      }
      
      // Set recognition level and language to all supported languages
      do {
        let requestRevision: Int
        if #available(iOS 16, *) {
          requestRevision = VNRecognizeTextRequestRevision3
        } else if #available(iOS 16, *) {
          requestRevision = VNRecognizeTextRequestRevision2
        } else {
          requestRevision = VNRecognizeTextRequestRevision1
        }
        
        let allLanguages = try VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: requestRevision)
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.recognitionLanguages = allLanguages
        textRecognitionRequest.usesLanguageCorrection = true
      } catch {
        //                completion(nil, error)
        print(error.localizedDescription)
        // do we need here return? I don't think so
      }
      
      try? requestHandler.perform([textRecognitionRequest])
      
    } else {
      
      UIGraphicsBeginPDFPageWithInfo(bounds, nil)
      image.draw(in: bounds)
    }
  }
  
  private static func changeCompressionImage(_ image: UIImage, quality: Double) -> UIImage {
    var compressionQuality: CGFloat = 0.0
    var baseHeight: Float = 595.2    // A4
    var baseWidth: Float = 841.8     // A4
    switch quality {
    case 0:
      baseHeight *= 2
      baseWidth *= 2
      compressionQuality = 0.3
    case 1:
      baseHeight *= 3
      baseWidth *= 3
      compressionQuality = 0.4
    case 2:
      baseHeight *= 4
      baseWidth *= 4
      compressionQuality = 0.5
    case 3:
      baseHeight *= 5
      baseWidth *= 5
      compressionQuality = 0.6
    case 4:
      baseHeight = Float(image.size.height)
      baseWidth = Float(image.size.width)
      compressionQuality = 0.6
    default:
      break
    }
    
    var newHeight = Float(image.size.height)
    var newWidth = Float(image.size.width)
    var imgRatio: Float = newWidth / newHeight
    let baseRatio: Float = baseWidth / baseHeight
    
    if newHeight > baseHeight || newWidth > baseWidth {
      if imgRatio < baseRatio {
        imgRatio = baseHeight / newHeight
        newWidth = imgRatio * newWidth
        newHeight = baseHeight
      } else if imgRatio > baseRatio {
        imgRatio = baseWidth / newWidth
        newHeight = imgRatio * newHeight
        newWidth = baseWidth
      } else {
        newHeight = baseHeight
        newWidth = baseWidth
      }
    }
    
    let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(newWidth), height: CGFloat(newHeight))
    UIGraphicsBeginImageContext(rect.size)
    image.draw(in: rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
    UIGraphicsEndImageContext()
    if let imageData = imageData, let image = UIImage(data: imageData) {
      return image
    }
    return image
  }
  
  
  private static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, fontColor: UIColor) -> [NSAttributedString.Key: Any] {
    
    let constrainingDimension = min(bounds.width, bounds.height)
    let properBounds = CGRect(origin: .zero, size: bounds.size)
    var attributes: [NSAttributedString.Key: Any] = [:]
    
    let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    var bestFontSize: CGFloat = constrainingDimension
    
    // Search font (H)
    for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
      let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
      attributes[.font] = newFont
      
      let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
      
      if properBounds.contains(currentFrame) {
        bestFontSize = fontSize
        break
      }
    }
    
    // Search kern (W)
    let font = UIFont(descriptor: fontDescriptor, size: bestFontSize)
    attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: fontColor, NSAttributedString.Key.kern: 0] as [NSAttributedString.Key: Any]
    for kern in stride(from: 0, through: 100, by: 0.1) {
      let attributesTmp = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: fontColor, NSAttributedString.Key.kern: kern] as [NSAttributedString.Key: Any]
      let size = text.size(withAttributes: attributesTmp).width
      if size <= bounds.width {
        attributes = attributesTmp
      } else {
        break
      }
    }
    
    return attributes
  }
  
  
  // MARK: - New API added
  
  static func transform(images: [UIImage],
                        toSandwichPDFatURL url: URL,
                        isTextRecognition: Bool = true,
                        quality: CompressionLevel = .medium,
                        fontColor: UIColor = .clear,
                        completion: @escaping (_ error: Bool) -> Void) {
    DispatchQueue.global().async {
      let pdfData = NSMutableData()
      UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
      
      for image in images {
        draw(image: image, quality: quality, isTextRecognition: isTextRecognition, fontColor: fontColor)
      }
      
      UIGraphicsEndPDFContext()
      
      do {
        try pdfData.write(to: url, options: .atomic)
        DispatchQueue.main.async { completion(true) }
      } catch {
        print("Error: \(error)")
        DispatchQueue.main.async { completion(false) }
      }
    }
  }
  
  
  private static func draw(image: UIImage, quality: CompressionLevel, isTextRecognition: Bool, fontColor: UIColor) {
    let image = changeCompression(of: image, quality: quality)
    let bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
    
    if isTextRecognition {
      
      UIGraphicsBeginPDFPageWithInfo(bounds, nil)
      image.draw(in: bounds)
      
      let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
      
      let textRecognitionRequest = VNRecognizeTextRequest { request, _ in
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        for observation in observations {
          guard let textLine = observation.topCandidates(1).first else { continue }
          
          var t: CGAffineTransform = CGAffineTransform.identity
          t = t.scaledBy(x: image.size.width, y: -image.size.height)
          t = t.translatedBy(x: 0, y: -1)
          let rect = observation.boundingBox.applying(t)
          let text = textLine.string
          
          let font = UIFont.systemFont(ofSize: rect.size.height, weight: .regular)
          let attributes = bestFittingFont(for: text, in: rect, fontDescriptor: font.fontDescriptor, fontColor: fontColor)
          
          text.draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        }
      }
      
      // Set recognition level and language to all supported languages
      do {
        let requestRevision: Int
        if #available(iOS 16, *) {
          requestRevision = VNRecognizeTextRequestRevision3
        } else if #available(iOS 16, *) {
          requestRevision = VNRecognizeTextRequestRevision2
        } else {
          requestRevision = VNRecognizeTextRequestRevision1
        }
        
        let allLanguages = try VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: requestRevision)
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.recognitionLanguages = allLanguages
        textRecognitionRequest.usesLanguageCorrection = true
      } catch {
        //                completion(nil, error)
        print(error.localizedDescription)
        // do we need here return? I don't think so
      }
      
      try? requestHandler.perform([textRecognitionRequest])
      
    } else {
      
      UIGraphicsBeginPDFPageWithInfo(bounds, nil)
      image.draw(in: bounds)
    }
  }
  
  private static func draw(images: [UIImage], quality: CompressionLevel, isTextRecognition: Bool, fontColor: UIColor) {
    let pdfData = NSMutableData()
    
    UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
    
    for image in images {
      let image = changeCompression(of: image, quality: quality)
      let bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
      
      if isTextRecognition {
        
        UIGraphicsBeginPDFPageWithInfo(bounds, nil)
        image.draw(in: bounds)
        
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        
        let textRecognitionRequest = VNRecognizeTextRequest { request, _ in
          guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
          for observation in observations {
            guard let textLine = observation.topCandidates(1).first else { continue }
            
            var t: CGAffineTransform = CGAffineTransform.identity
            t = t.scaledBy(x: image.size.width, y: -image.size.height)
            t = t.translatedBy(x: 0, y: -1)
            let rect = observation.boundingBox.applying(t)
            let text = textLine.string
            
            let font = UIFont.systemFont(ofSize: rect.size.height, weight: .regular)
            let attributes = bestFittingFont(for: text, in: rect, fontDescriptor: font.fontDescriptor, fontColor: fontColor)
            
            text.draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
          }
        }
        
        // Set recognition level and language to all supported languages
        do {
          let requestRevision: Int
          if #available(iOS 16, *) {
            requestRevision = VNRecognizeTextRequestRevision3
          } else if #available(iOS 16, *) {
            requestRevision = VNRecognizeTextRequestRevision2
          } else {
            requestRevision = VNRecognizeTextRequestRevision1
          }
          
          let allLanguages = try VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: requestRevision)
          textRecognitionRequest.recognitionLevel = .accurate
          textRecognitionRequest.recognitionLanguages = allLanguages
          textRecognitionRequest.usesLanguageCorrection = true
        } catch {
          print(error.localizedDescription)
        }
        
        try? requestHandler.perform([textRecognitionRequest])
        
      } else {
        
        UIGraphicsBeginPDFPageWithInfo(bounds, nil)
        image.draw(in: bounds)
      }
    }
    
    UIGraphicsEndPDFContext()
  }
  
  private static func changeCompression(of image: UIImage, quality: CompressionLevel) -> UIImage {
    var compressionQuality: CGFloat = 0.0
    var baseHeight: Float = 595.2    // A4
    var baseWidth: Float = 841.8     // A4
    switch quality {
    case .low:
      baseHeight *= 2
      baseWidth *= 2
      compressionQuality = 0.3
    case .medium:
      baseHeight *= 3
      baseWidth *= 3
      compressionQuality = 0.4
    case .high:
      baseHeight *= 4
      baseWidth *= 4
      compressionQuality = 0.5
    case .veryHigh:
      baseHeight *= 5
      baseWidth *= 5
      compressionQuality = 0.6
    case .original:
      baseHeight = Float(image.size.height)
      baseWidth = Float(image.size.width)
      compressionQuality = 0.6
    }
    
    var newHeight = Float(image.size.height)
    var newWidth = Float(image.size.width)
    var imgRatio: Float = newWidth / newHeight
    let baseRatio: Float = baseWidth / baseHeight
    
    if newHeight > baseHeight || newWidth > baseWidth {
      if imgRatio < baseRatio {
        imgRatio = baseHeight / newHeight
        newWidth = imgRatio * newWidth
        newHeight = baseHeight
      } else if imgRatio > baseRatio {
        imgRatio = baseWidth / newWidth
        newHeight = imgRatio * newHeight
        newWidth = baseWidth
      } else {
        newHeight = baseHeight
        newWidth = baseWidth
      }
    }
    
    let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(newWidth), height: CGFloat(newHeight))
    UIGraphicsBeginImageContext(rect.size)
    image.draw(in: rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
    UIGraphicsEndImageContext()
    if let imageData = imageData, let image = UIImage(data: imageData) {
      return image
    }
    return image
  }
}

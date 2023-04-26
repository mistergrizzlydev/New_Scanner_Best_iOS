import PDFKit

/*
 // Example usage
 let originalImage = UIImage(named: "example.jpg")!
 let pdfData = originalImage.toPDF()!
 let pdfDocument = PDFDocument(data: pdfData)!
 let pdfPage = pdfDocument.page(at: 0)!
 let extractedImage = pdfPage.toImage()!
 */
extension UIImage {
  func toPDF() -> Data? {
    let pdfDocument = PDFDocument()
    let pdfPage = PDFPage(image: self)
    pdfDocument.insert(pdfPage!, at: 0)
    return pdfDocument.dataRepresentation()
  }
}

/*
 // Example usage
 let images = [UIImage(named: "image1.jpg")!, UIImage(named: "image2.jpg")!]
 let pdfData = images.toPDF()!
 // Save the PDF data to a file or upload it to a server
 */
extension Array where Element == UIImage {
  func toPDF() -> Data? {
    let pdfDocument = PDFDocument()
    for image in self {
      let pdfPage = PDFPage(image: image)
      pdfDocument.insert(pdfPage!, at: pdfDocument.pageCount)
    }
    return pdfDocument.dataRepresentation()
  }
}

extension PDFPage {
  func toImage() -> UIImage? {
    let pageBounds = self.bounds(for: .mediaBox)
    let renderer = UIGraphicsImageRenderer(size: pageBounds.size)
    let image = renderer.image { (context) in
      UIColor.white.set()
      context.fill(pageBounds)
      context.cgContext.translateBy(x: 0.0, y: pageBounds.size.height)
      context.cgContext.scaleBy(x: 1.0, y: -1.0)
      self.draw(with: .mediaBox, to: context.cgContext)
    }
    return image
  }
}

import PDFKit

extension Array where Element == UIImage {
  func toSandwichPDF() -> Data? {
    let pdfDocument = PDFDocument()
    
    // Add each image to the PDF document as a new page
    for image in self {
      let pdfPage = PDFPage(image: image)!
      pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
    }
    
    // Extract the text from each page in the document
    var text = ""
    for i in 0..<pdfDocument.pageCount {
      let page = pdfDocument.page(at: i)!
      if let pageText = page.string {
        text += pageText
      }
    }
    
    // Create a new PDF with the images and text overlaid
    let pdfPage = pdfDocument.page(at: 0)!
    let pageSize = pdfPage.bounds(for: .mediaBox).size
    let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height))
    
    let pdfData = renderer.pdfData { (context) in
      context.beginPage()
      
      // Draw the images on the page
      for i in 0..<pdfDocument.pageCount {
        let page = pdfDocument.page(at: i)!
        let imageRect = page.bounds(for: .mediaBox)
        let image = UIImage(cgImage: page.thumbnail(of: CGSize(width: imageRect.width, height: imageRect.height), for: .mediaBox).cgImage!)
        image.draw(in: imageRect)
      }
      
      // Draw the text on the page
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .left
      let textAttributes = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
        NSAttributedString.Key.paragraphStyle: paragraphStyle
      ]
      let textRect = CGRect(x: 20, y: 20, width: pageSize.width - 40, height: pageSize.height - 40)
      text.draw(in: textRect, withAttributes: textAttributes)
    }
    return pdfData
  }
}

enum PDFConstants {
    static let A4FormatRectangle = CGRect(x: 0, y: 0, width: 595, height: 842)
    static let LetterFormatRectangle = CGRect(x: 0, y: 0, width: 612, height: 792)
    static let LegalFormatRectangle = CGRect(x: 0, y: 0, width: 612, height: 1008)
}

extension UIImage {
    func getPDFData(page rect: CGRect = PDFConstants.A4FormatRectangle) -> Data {
        
        let maxWidth        = rect.width
        let maxHeight       = rect.height
        
        let aspectWidth     = maxWidth / self.size.width
        let aspectHeight    = maxHeight / self.size.height
        let aspectRatio     = min(aspectWidth, aspectHeight)
        
        let scaledWidth     = self.size.width * aspectRatio
        let scaledHeight    = self.size.height * aspectRatio
        
        let imageYPosition  = (maxHeight - scaledHeight) / 2.0 // So it's centred on Y axis
        let imageXPosition  = (maxWidth - scaledWidth) / 2.0 // So it's centred on X axis
        let imageRect       = CGRect(x: imageXPosition, y: imageYPosition, width: scaledWidth, height: scaledHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: rect)
        let pdfData = renderer.pdfData { context in
            context.beginPage()
            self.draw(in: imageRect)
        }
        
        return pdfData
    }
    
    static func getPDFDataFromImages(_ images: [UIImage], page rect: CGRect = PDFConstants.A4FormatRectangle) -> Data {
        
        var pdfData = Data()
        
        let renderer = UIGraphicsPDFRenderer(bounds: rect)
        pdfData = renderer.pdfData { context in
            for image in images {
                let maxWidth        = rect.width
                let maxHeight       = rect.height
                
                let aspectWidth     = maxWidth / image.size.width
                let aspectHeight    = maxHeight / image.size.height
                let aspectRatio     = min(aspectWidth, aspectHeight)
                
                let scaledWidth     = image.size.width * aspectRatio
                let scaledHeight    = image.size.height * aspectRatio
                
                let imageYPosition  = (maxHeight - scaledHeight) / 2.0 // So it's centred on Y axis
                let imageXPosition  = (maxWidth - scaledWidth) / 2.0 // So it's centred on X axis
                let imageRect       = CGRect(x: imageXPosition, y: imageYPosition, width: scaledWidth, height: scaledHeight)
                
                context.beginPage()
                image.draw(in: imageRect)
            }
        }
        
        return pdfData
    }
}
import Vision

extension UIImage {
  func testVision() -> PDFDocument? {
    let request = VNRecognizeTextRequest()

    let handler = VNImageRequestHandler(cgImage: cgImage!, options: [:])
    try? handler.perform([request])

    guard let observations = request.results else { return nil }

    for observation in observations {
        guard let topCandidate = observation.topCandidates(1).first else { continue }
        print("Detected text: \(topCandidate.string)")
        print("Bounding box: \(observation.boundingBox)")
    }
    
    return createSearchablePDF(from: self, with: observations)
  }
}

import PDFKit
import Vision

private func createSearchablePDF(from image: UIImage, with observations: [VNRecognizedTextObservation]) -> PDFDocument? {
    // Create a new PDF document
    let pdfDocument = PDFDocument()
    
    // Create a PDF page with the image
    let pdfPage = PDFPage(image: image)
    
    // Get the size of the image and PDF page
    let imageSize = image.size
    let pdfPageSize = pdfPage?.bounds(for: .mediaBox).size ?? .zero
    
    // Calculate the image aspect ratio
    let aspectRatio = imageSize.width / imageSize.height
    
    // Iterate over the text observations and add each one to the PDF page
    for observation in observations {
        // Get the text and bounding box from the observation
        let text = observation.topCandidates(1).first?.string ?? ""
        let boundingBox = observation.boundingBox
        
        // Calculate the position and size of the text box in PDF coordinates
        let pdfX = pdfPageSize.width * boundingBox.origin.x
        let pdfY = pdfPageSize.height * (1 - boundingBox.origin.y - boundingBox.height)
        let pdfWidth = pdfPageSize.width * boundingBox.width
        let pdfHeight = pdfPageSize.height * boundingBox.height * aspectRatio
        
        let textBox = CGRect(x: pdfX, y: pdfY, width: pdfWidth, height: pdfHeight)
        
        // Create a new annotation with the text box and text
        let annotation = PDFAnnotation(bounds: textBox, forType: .highlight, withProperties: nil)
        annotation.color = .yellow
        annotation.contents = text
        
        // Add the annotation to the PDF page
        pdfPage?.addAnnotation(annotation)
    }
    
    // Add the PDF page to the document
    if let pdfPage = pdfPage {
        pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
    }
    
    // Return the completed PDF document
    return pdfDocument
}

/*
import UIKit
import PDFKit
import Vision

func createSearchablePDF(from image: UIImage) -> PDFDocument? {
    
    guard let cgImage = image.cgImage else { return nil }
    
    // Create a new PDF document
    let pdfDocument = PDFDocument()
    
    // Create a new page with the same dimensions as the image
    let pageSize = CGSize(width: cgImage.width, height: cgImage.height)
    let pdfPage = PDFPage(bounds: CGRect(origin: .zero, size: pageSize))
    
    // Create an empty attributed string to hold the text
    let attributedString = NSMutableAttributedString()
    
    // Perform text recognition on the image
    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    let request = VNRecognizeTextRequest()
    
    do {
        try requestHandler.perform([request])
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return nil }
        
        // Add the recognized text to the attributed string with its position information
        for observation in observations {
            guard let bestCandidate = observation.topCandidates(1).first else { continue }
            
            let text = bestCandidate.string
            let boundingBox = observation.boundingBox
            
            let x = boundingBox.origin.x * pageSize.width
            let y = (1 - boundingBox.origin.y) * pageSize.height - boundingBox.height * pageSize.height
            let width = boundingBox.width * pageSize.width
            let height = boundingBox.height * pageSize.height
            let rect = CGRect(x: x, y: y, width: width, height: height)
            
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
            let attributedSubstring = NSAttributedString(string: text, attributes: attributes)
            
            let textContainer = NSTextContainer(size: rect.size)
            let layoutManager = NSLayoutManager()
            layoutManager.addTextContainer(textContainer)
            attributedString.append(attributedSubstring)
            
            let range = NSRange(location: attributedString.length - 1, length: 1)
            let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            
            textContainer.lineFragmentPadding = 0
            textContainer.maximumNumberOfLines = 1
            textContainer.lineBreakMode = .byTruncatingTail
            textContainer.size = rect.size
            
            let textStorage = NSTextStorage(attributedString: attributedSubstring)
            textStorage.addLayoutManager(layoutManager)
            
            layoutManager.drawBackground(forGlyphRange: glyphRange, at: rect.origin)
            layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: rect.origin)
        }
        
    } catch {
        print("Text recognition error: \(error.localizedDescription)")
        return nil
    }
    
    // Set the attributed string as the text on the PDF page
    let text = PDFPage.attributedStringWithMarkup(attributedString)
    pdfPage?.addAnnotation(PDFAnnotation(bounds: pdfPage!.bounds(for: .cropBox), forType: .text, withProperties: nil))
    pdfPage?.addAnnotation(PDFAnnotation(bounds: pdfPage!.bounds(for: .cropBox), forType: .highlight, withProperties: [PDFAnnotationTextKey: text]))
    
  // Add the page to the PDF document and return it
  pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
  return pdfDocument
  }

  // Function to extract the text and bounds from an image using Vision framework
func extractTextAndBounds(from image: UIImage) -> [(text: String, bounds: CGRect)] {
  guard let cgImage = image.cgImage else { return [] }
  
  var results: [(text: String, bounds: CGRect)] = []
  
  let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
  
  let textDetectionRequest = VNDetectTextRectanglesRequest(completionHandler: { request, error in
    guard let observations = request.results as? [VNTextObservation] else { return }
    
    for observation in observations {
      guard let rects = observation.characterBoxes else { continue }
      let text = observation.string
      var combinedRect = CGRect.null
      
      for rect in rects {
        combinedRect = combinedRect.union(rect.boundingBox)
      }
      
      let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
      let boundingBox = combinedRect.applying(CGAffineTransform(scaleX: imageSize.width, y: imageSize.height))
      
      results.append((text, boundingBox))
    }
  })
  
  textDetectionRequest.reportCharacterBoxes = true
  
  do {
    try requestHandler.perform([textDetectionRequest])
  } catch {
    print("Error detecting text: \(error)")
  }
  
  return results
}
// Function to create a searchable PDF document from an image with extracted text
func createSearchablePDF(from image: UIImage) -> PDFDocument {
  let pdfDocument = PDFDocument()
  let pdfPage = PDFPage(image: image)
  
  // Extract text and bounds from the image using Vision framework
  let textAndBounds = extractTextAndBounds(from: image)
  
  // Loop through the text and bounds, adding each to the PDF page as an annotation
  for (text, bounds) in textAndBounds {
    let annotation = PDFAnnotation(bounds: bounds, forType: .highlight, withProperties: nil)
    annotation.color = UIColor.yellow.withAlphaComponent(0.5)
    annotation.contents = text
    
    pdfPage?.addAnnotation(annotation)
  }
  
  // Add the page to the PDF document and return it
  pdfDocument.insert(pdfPage!, at: pdfDocument.pageCount)
  return pdfDocument
  
}
*/
/*
import Vision
import PDFKit

class PDFManager {
    
    static func createSearchablePDF(from image: UIImage, with text: String) -> PDFDocument? {
        
        // Create a PDF document
        let pdfDocument = PDFDocument()
        
        // Create a PDF page with the image
        let pdfPage = PDFPage(image: image)
        
        // Get the image size and aspect ratio
        let imageSize = image.size
        let aspectRatio = imageSize.width / imageSize.height
        
        // Get the PDF page bounds
        let pdfBounds = pdfPage?.bounds(for: .cropBox) ?? CGRect.zero
        
        // Calculate the size of the text bounding box
        let textWidth = pdfBounds.width * 0.8
        let textHeight = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                           options: [.usesLineFragmentOrigin, .usesFontLeading],
                                           attributes: [.font: UIFont.systemFont(ofSize: 12)],
                                           context: nil).height
        let textX = pdfBounds.width * 0.1
        let textY = pdfBounds.height * 0.1
        let textRect = CGRect(x: textX, y: textY, width: textWidth, height: textHeight)
        
        // Add the text to the PDF page
        pdfPage?.addAnnotation(createTextAnnotation(with: text, in: textRect))
        
        // Add the page to the PDF document and return it
        if let page = pdfPage {
            pdfDocument.insert(page, at: pdfDocument.pageCount)
            return pdfDocument
        } else {
            return nil
        }
    }
    
    private static func createTextAnnotation(with text: String, in rect: CGRect) -> PDFAnnotation {
        let textAnnotation = PDFAnnotation(bounds: rect, forType: .freeText, withProperties: nil)
        textAnnotation.font = UIFont.systemFont(ofSize: 12)
        textAnnotation.color = UIColor.black
        textAnnotation.contents = text
        textAnnotation.alignment = .left
      textAnnotation.isMultiline = true
        textAnnotation.isEditable = false
//        textAnnotation.isScrollable = false
        textAnnotation.shouldPrint = true
        return textAnnotation
    }
    
    static func detectText(in image: UIImage, completion: @escaping (String?) -> Void) {
        
        // Create a Vision request handler
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!)
        
        // Create a Vision text recognition request
        let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            
            // Check for errors
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            // Extract the recognized text and concatenate it
            var recognizedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                recognizedText += topCandidate.string
            }
            
            completion(recognizedText)
        }
        
        // Set the recognition level and language
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.recognitionLanguages = ["en_US"]
        
        // Perform the text recognition request
        do {
            try requestHandler.perform([textRecognitionRequest])
        } catch {
            completion(nil)
        }
    }
}

*/

//import UIKit
//import Vision
//import PDFKit
//
//class PDFManager {
//
//    static func createSearchablePDF(from image: UIImage) -> PDFDocument? {
//
//        guard let cgImage = image.cgImage else { return nil }
//
//        // Create a new PDF document
//        let pdfDocument = PDFDocument()
//
//        // Create a new page with the same dimensions as the image
//        let pageSize = CGSize(width: cgImage.width, height: cgImage.height)
//        let pdfPage = PDFPage(image: image)//(bounds: CGRect(origin: .zero, size: pageSize))
//
//        // Create an empty attributed string to hold the text
//        let attributedString = NSMutableAttributedString()
//
//        // Perform text recognition on the image
//        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        let request = VNRecognizeTextRequest()
//
//        do {
//            try requestHandler.perform([request])
//          guard let observations = request.results else { return nil }
//
//            // Add the recognized text to the attributed string with its position information
//            for observation in observations {
//                guard let bestCandidate = observation.topCandidates(1).first else { continue }
//
//                let text = bestCandidate.string
//                let boundingBox = observation.boundingBox
//
//                let x = boundingBox.origin.x * pageSize.width
//                let y = (1 - boundingBox.origin.y) * pageSize.height - boundingBox.height * pageSize.height
//                let width = boundingBox.width * pageSize.width
//                let height = boundingBox.height * pageSize.height
//                let rect = CGRect(x: x, y: y, width: width, height: height)
//
//                let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
//                let attributedSubstring = NSAttributedString(string: text, attributes: attributes)
//
//                let textContainer = NSTextContainer(size: rect.size)
//                let layoutManager = NSLayoutManager()
//                layoutManager.addTextContainer(textContainer)
//                attributedString.append(attributedSubstring)
//
//                let range = NSRange(location: attributedString.length - 1, length: 1)
//                let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
//
//                textContainer.lineFragmentPadding = 0
//                textContainer.maximumNumberOfLines = 1
//                textContainer.lineBreakMode = .byTruncatingTail
//                textContainer.size = rect.size
//
//                let textStorage = NSTextStorage(attributedString: attributedSubstring)
//                textStorage.addLayoutManager(layoutManager)
//
//                layoutManager.drawBackground(forGlyphRange: glyphRange, at: rect.origin)
//                layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: rect.origin)
//            }
//
//        } catch {
//            print("Text recognition error: \(error.localizedDescription)")
//            return nil
//        }
//
//        // Set the attributed string as the text on the PDF page
////        let text = PDFPage.attributedStringWithMarkup(attributedString)
////        pdfPage?.addAnnotation(PDFAnnotation(bounds: pdfPage!.bounds(for: .cropBox), forType: .text, withProperties: nil))
////        pdfPage?.addAnnotation(PDFAnnotation(bounds: pdfPage!.bounds(for: .cropBox), forType: .highlight, withProperties: [PDFAnnotationTextKey: text]))
////
////        // Add the page to the PDF document and return it
////        pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
//
//      guard let pdfPage = pdfPage else { return nil }
////      let text = attributedString
////      let aa = PDFAnnotation(bounds: pdfPage.bounds(for: .cropBox), forType: .text, withProperties: nil)
////      let textAnnotation = PDFAnnotation(bounds: pdfPage.bounds(for: .cropBox), forType: .text, withProperties: nil)
////      textAnnotation.attributedString = text
//
//      let textAnnotation = TextAnnotation(bounds: pdfPage.bounds(for: .cropBox), forType: .text, withProperties: nil)
//      textAnnotation.widgetStringValue = attributedString.string
//      pdfPage.addAnnotation(textAnnotation)
//
//        return pdfDocument
//    }
//}
//
//
//class TextAnnotation:  PDFAnnotation {
//
//  var currentText: String?
////  var pageBounds: CGRect
//
//  override init(bounds: CGRect, forType annotationType: PDFAnnotationSubtype, withProperties properties: [AnyHashable : Any]?) {
//    super.init(bounds: bounds, forType: annotationType, withProperties: properties)
//
//    self.widgetFieldType = PDFAnnotationWidgetSubtype(rawValue: PDFAnnotationWidgetSubtype.text.rawValue)
//
//    self.font = UIFont.systemFont(ofSize: 80)
//
//    self.isMultiline = true
//
//    self.widgetStringValue = "Text Here"
//
//    self.currentText = self.widgetStringValue!
//  }
//
//  override func draw(with box: PDFDisplayBox, in context: CGContext) {
//    UIGraphicsPushContext(context)
//    context.saveGState()
//
//    let paragraphStyle = NSMutableParagraphStyle()
//    paragraphStyle.alignment = .center
//
//    let attributes: [NSAttributedString.Key: Any] = [
//      .paragraphStyle: paragraphStyle,
//      .font: UIFont.systemFont(ofSize: 80),
//      .foregroundColor: UIColor.red
//    ]
//
//    widgetStringValue?.draw(in: bounds, withAttributes: attributes)
//
//    context.restoreGState()
//    UIGraphicsPopContext()
//  }
//
//  required init?(coder aDecoder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//}
//
//extension UIImage {
//    func createSearchablePDF() -> PDFDocument? {
//        guard let cgImage = self.cgImage else { return nil }
//
//        // Create a new PDF document
//        let pdfDocument = PDFDocument()
//
//        // Create a new page with the same dimensions as the image
//        let pageSize = CGSize(width: cgImage.width, height: cgImage.height)
//        let pdfPage = PDFPage(bounds: CGRect(origin: .zero, size: pageSize))
//
//        // Create an empty attributed string to hold the text
//        let attributedString = NSMutableAttributedString()
//
//        // Perform text recognition on the image
//        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        let request = VNRecognizeTextRequest()
//
//        do {
//            try requestHandler.perform([request])
//            guard let observations = request.results as? [VNRecognizedTextObservation] else { return nil }
//
//            // Add the recognized text to the attributed string with its position information
//            for observation in observations {
//                guard let bestCandidate = observation.topCandidates(1).first else { continue }
//
//                let text = bestCandidate.string
//                let boundingBox = observation.boundingBox
//
//                let x = boundingBox.origin.x * pageSize.width
//                let y = (1 - boundingBox.origin.y) * pageSize.height - boundingBox.height * pageSize.height
//                let width = boundingBox.width * pageSize.width
//                let height = boundingBox.height * pageSize.height
//                let rect = CGRect(x: x, y: y, width: width, height: height)
//
//                let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
//                let attributedSubstring = NSAttributedString(string: text, attributes: attributes)
//
//                let textContainer = NSTextContainer(size: rect.size)
//                let layoutManager = NSLayoutManager()
//                layoutManager.addTextContainer(textContainer)
//                attributedString.append(attributedSubstring)
//
//                let range = NSRange(location: attributedString.length - 1, length: 1)
//                let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
//
//                textContainer.lineFragmentPadding = 0
//                textContainer.maximumNumberOfLines = 1
//                textContainer.lineBreakMode = .byTruncatingTail
//                textContainer.size = rect.size
//
//                let textStorage = NSTextStorage(attributedString: attributedSubstring)
//                textStorage.addLayoutManager(layoutManager)
//
//                layoutManager.drawBackground(forGlyphRange: glyphRange, at: rect.origin)
//                layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: rect.origin)
//            }
//
//        } catch {
//            print("Text recognition error: \(error.localizedDescription)")
//            return nil
//        }
//
//        // Set the attributed string as the text on the PDF page
////        let text = PDFPage.attributedStringWithMarkup(attributedString)
//      guard let pdfPage = pdfPage else { return nil }
//      pdfPage.addAnnotation(PDFAnnotation(bounds: pdfPage.bounds(for: .cropBox), forType: .text, withProperties: [PDFAnnotationWidgetSubtype.text: attributedString.string]))
//
//        // Add the page to the PDF document and return it
//        pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
//        return pdfDocument
//    }
//}


extension UIImage {
  var pdf: PDFDocument? {
    let pdfDocument = PDFDocument()
    if let pdfPage = PDFPage(image: self) {
      pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
      return pdfDocument
    }
    return nil
  }
}

extension UIImage {
    func withGrayLayer() -> UIImage? {
//        let imageSize = self.size
//        let renderer = UIGraphicsImageRenderer(size: imageSize)
//        return renderer.image { context in
//            // Draw the original image
//            self.draw(in: CGRect(origin: CGPoint.zero, size: imageSize))
//
//            // Draw a gray layer on top of the image
//            UIColor.gray.withAlphaComponent(0.2).setFill()
//            context.fill(CGRect(origin: CGPoint.zero, size: imageSize))
//        }

      // Create a new color with alpha component
      let transparentColor = UIColor.black.withAlphaComponent(0.5)

      // Create a new image context with the same size as the original image
      UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

      // Draw the original image into the context
      draw(in: CGRect(x: 0, y: 0, width:size.width, height: size.height))

      // Draw the transparent color on top of the original image
      transparentColor.setFill()
      UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))

      // Get the new image from the context
      let newImage = UIGraphicsGetImageFromCurrentImageContext()

      // End the context
      UIGraphicsEndImageContext()
      return newImage
    }
}

extension UIImage {
    func toPDF() -> PDFDocument? {
        // Add a gray layer with 0.2 alpha on top of the UIImage
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        UIColor.gray.withAlphaComponent(0.2).setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: self.size))
        let overlayImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Create a PDF document with the UIImage and the gray layer
        let pdfDocument = PDFDocument()
        let page = PDFPage(image: overlayImage ?? self)
        pdfDocument.insert(page!, at: pdfDocument.pageCount)
        
        return pdfDocument
    }
}

import UIKit

extension UIImage {
    
    // colorize image with given tint color
    // this is similar to Photoshop's "Color" layer blend mode
    // this is perfect for non-greyscale source images, and images that have both highlights and shadows that should be preserved
    // white will stay white and black will stay black as the lightness of the image is preserved
    func tint(tintColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw black background - workaround to preserve color of partially transparent pixels
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            // draw original image
            context.setBlendMode(.normal)
            context.draw(self.cgImage!, in: rect)
            
            // tint image (loosing alpha) - the luminosity of the original image is preserved
            context.setBlendMode(.color)
            tintColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    // fills the alpha channel of the source image with the given color
    // any color information except to the alpha channel will be ignored
    func fillAlpha(fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
//            context.fillCGContextFillRect(context, rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}

//import UIKit
//import Vision
//
//extension UIImage {
//  func recognizeTextInImage() {
//    guard let cgImage = cgImage else {
//      print("Unable to get CGImage from UIImage.")
//      return
//    }
//
//    let requestHandler = VNImageRequestHandler(cgImage: cgImage)
//    let request = VNRecognizeTextRequest()
//
//    do {
//      try requestHandler.perform([request])
//    } catch {
//      print("Error recognizing text: \(error.localizedDescription)")
//      return
//    }
//
//    guard let observations = request.results else {
//      print("No text was recognized.")
//      return
//    }
//
//    for observation in observations {
//      guard let topCandidate = observation.topCandidates(1).first else {
//        print("Unable to get top candidate for observation.")
//        continue
//      }
//
//      let text = topCandidate.string
//      let font = UIFont(descriptor: topCandidate.textRecognitionLevel == .accurate ? topCandidate.fonts[0] : UIFont.systemFont(ofSize: 17), size: 17)
//      let boundsRect = observation.boundingBox
//
//      print("Text: \(text), Font: \(font), Bounds: \(boundsRect)")
//    }
//  }
//}

import UIKit
import Vision

extension UIImage {
  func recognizeTextInImage() {
    guard let cgImage = cgImage else {
      print("Unable to get CGImage from UIImage.")
      return
    }
    
    let requestHandler = VNImageRequestHandler(cgImage: cgImage)
    let request = VNRecognizeTextRequest { request, error in
      if let error = error {
        print("Error recognizing text: \(error.localizedDescription)")
        return
      }
      
      guard let observations = request.results as? [VNRecognizedTextObservation] else {
        print("No text was recognized.")
        return
      }
      
      for observation in observations {
        guard let topCandidate = observation.topCandidates(1).first else {
          print("Unable to get top candidate for observation.")
          continue
        }
        
        let text = topCandidate.string
        let topConfidence = topCandidate.confidence == 1.0
        let attributedString = NSAttributedString(string: text)
        let font = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont ?? UIFont.systemFont(ofSize: 17)
        let boundsRect = observation.boundingBox

        print("Text: \(text), Font: \(font), Bounds: \(boundsRect)")
      }
    }
    request.recognitionLevel = .accurate
    
    do {
      try requestHandler.perform([request])
    } catch {
      print("Error recognizing text: \(error.localizedDescription)")
      return
    }
  }
}

extension UIImage {
  func recognizeTextInImageAndDrawOnPDF(_ completion: @escaping ((PDFDocument?) -> Void)) {
        guard let cgImage = cgImage else {
            print("Unable to get CGImage from UIImage.")
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Error recognizing text: \(error.localizedDescription)")
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No text was recognized.")
                return
            }

            // Create a new PDFDocument
            let pdfDocument = PDFDocument()

            // Create a new page in the PDFDocument
            let pdfPage = PDFPage()

            // Get the graphics context for the PDFPage
            guard let context = UIGraphicsGetCurrentContext() else {
                print("Unable to get graphics context.")
                return
            }

            // Draw the recognized text on the PDFPage
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    print("Unable to get top candidate for observation.")
                    continue
                }

                let text = topCandidate.string
                let attributedString = NSAttributedString(string: text)
                let font = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont ?? UIFont.systemFont(ofSize: 17)
                let boundsRect = observation.boundingBox

                // Set the font and font size for the text
                let fontRef = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)

                // Set the text color
                context.setFillColor(UIColor.black.cgColor)

                // Draw the text on the PDFPage
              context.setFont(fontRef as! CGFont)
                context.translateBy(x: boundsRect.origin.x, y: self.size.height - boundsRect.origin.y - boundsRect.height)
                context.scaleBy(x: 1.0, y: -1.0)
                let line = CTLineCreateWithAttributedString(attributedString as CFAttributedString)
                CTLineDraw(line, context)
                context.scaleBy(x: 1.0, y: -1.0)
                context.translateBy(x: -boundsRect.origin.x, y: -(self.size.height - boundsRect.origin.y - boundsRect.height))
            }

            // Add the PDFPage to the PDFDocument
            pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)

            // Save the PDFDocument to disk
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let pdfFilePath = documentsDirectory.appendingPathComponent("recognizedText.pdf")
                pdfDocument.write(to: pdfFilePath)
              completion(pdfDocument)
            }
        }
        request.recognitionLevel = .accurate

        do {
            try requestHandler.perform([request])
        } catch {
            print("Error recognizing text: \(error.localizedDescription)")
            return
        }
    }
}

extension UIImage {
    func recognizeTextInImageAndDrawOnPDF2(_ completion: @escaping ((PDFDocument?) -> Void)) {
        guard let cgImage = cgImage else {
            print("Unable to get CGImage from UIImage.")
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Error recognizing text: \(error.localizedDescription)")
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No text was recognized.")
                return
            }

            // Create a new PDFDocument
            let pdfDocument = PDFDocument()

            // Create a new page in the PDFDocument
            guard let pdfPage = PDFPage(image: self) else {
                print("Unable to create PDFPage.")
                return
            }

            // Add the annotations to the PDFPage
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    print("Unable to get top candidate for observation.")
                    continue
                }

                let text = topCandidate.string
                let attributedString = NSAttributedString(string: text)
                let font = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont ?? UIFont.systemFont(ofSize: 17)
                let boundsRect = observation.boundingBox

                // Create a new PDFAnnotation
                let textAnnotation = PDFAnnotation(bounds: boundsRect, forType: .text, withProperties: nil)
                textAnnotation.font = font
                textAnnotation.color = UIColor.black
                textAnnotation.contents = text

                // Add the PDFAnnotation to the PDFPage
                pdfPage.addAnnotation(textAnnotation)
            }

            // Add the PDFPage to the PDFDocument
            pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)

            // Save the PDFDocument to disk
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let pdfFilePath = documentsDirectory.appendingPathComponent("recognizedText.pdf")
                pdfDocument.write(to: pdfFilePath)
                completion(pdfDocument)
            }
//          completion(pdfDocument)
        }
        request.recognitionLevel = .accurate

        do {
            try requestHandler.perform([request])
        } catch {
            print("Error recognizing text: \(error.localizedDescription)")
            return
        }
    }
}

//extension UIImage {
//  func pdf(with text: String) -> PDFDocument? {
//    let pdfDocument = PDFDocument()
//    if let pdfPage = PDFPage(image: self) {
//      // add text on page
//      pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
//      return pdfDocument
//    }
//    return nil
//  }
//}

extension UIImage {
    func pdf(with text: String, in boundingBox: CGRect) -> PDFDocument? {
        let pdfDocument = PDFDocument()
        if let pdfPage = PDFPage(image: self) {
            // Add the PDFPage to the PDFDocument
            pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)

            // Create a new PDFAnnotation with the given text and bounding box
            let annotation = PDFAnnotation(bounds: boundingBox, forType: .text, withProperties: nil)
            annotation.contents = text
            annotation.color = .yellow

            // Add the annotation to the PDFPage
            pdfPage.addAnnotation(annotation)

            return pdfDocument
        }
        return nil
    }
  
  func write(pdfDocument: PDFDocument, bounds: CGRect) -> PDFDocument? {
    // Define the font and text to be drawn
    let font = UIFont.systemFont(ofSize: 12)
    let text = "Hello, World!"

    let currentContext = UIGraphicsGetCurrentContext()

    // Create a text attributes dictionary with the font
    let textAttributes = [NSAttributedString.Key.font: font]

    // Calculate the size of the text
    let textSize = text.size(withAttributes: textAttributes)

    // Define the point at which to draw the text
    let textPoint = CGPoint(x: bounds.midX - textSize.width / 2,
                            y: bounds.midY - textSize.height / 2)

    // Draw the text on the PDF page
    text.draw(at: textPoint, withAttributes: textAttributes)

//    // Save the PDF document to a file
//    let fileURL = URL(fileURLWithPath: "/path/to/file.pdf")
//    pdfDocument.write(to: fileURL)

    return pdfDocument
  }
}

func drawText(in pdfURL: URL,
              text: NSString = "Hello world",
              font: UIFont = UIFont.systemFont(ofSize: 17),
              textRect: CGRect = CGRect(x: 5, y: 3, width: 125, height: 18)) {
  
  //    let fileName = "pdffilename.pdf"
  //    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
  //    let documentsDirectory = paths[0] as NSString
  //    let pathForPDF = documentsDirectory.appending("/" + fileName)
  
//  UIGraphicsBeginPDFContextToFile(pdfURL.path, CGRect.zero, nil)
//
//  UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 100, height: 400), nil)
  
  
  let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
  paragraphStyle.alignment = NSTextAlignment.left
  paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
  
  let textColor = UIColor.black
  
  let textFontAttributes = [
    NSAttributedString.Key.font: font,
    NSAttributedString.Key.foregroundColor: textColor,
    NSAttributedString.Key.paragraphStyle: paragraphStyle
  ]
  
  text.draw(in: textRect, withAttributes: textFontAttributes)
  
//  UIGraphicsEndPDFContext()
}






























extension UIImage {
  func pdf(with text: String) -> PDFDocument? {
    let pdfDocument = PDFDocument()
    if let pdfPage = PDFPage(image: self) {
      // Get the page bounds
      let pageBounds = pdfPage.bounds(for: .cropBox)

      // Create a new attributed string with the text and set its font and color
      let attributedString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.black])

      // Create a framesetter with the attributed string
      let framesetter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)

      // Create a rectangular path with the page bounds
      let path = CGPath(rect: pageBounds, transform: nil)

      // Create a new frame with the framesetter and path
      let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedString.length), path, nil)

      // Get the graphics context for the PDFPage
      guard let context = UIGraphicsGetCurrentContext() else {
          print("Unable to get graphics context.")
          return nil
      }

      // Draw the frame on the PDFPage
      context.translateBy(x: 0.0, y: pageBounds.size.height)
      context.scaleBy(x: 1.0, y: -1.0)
      CTFrameDraw(frame, context)
      context.scaleBy(x: 1.0, y: -1.0)
      context.translateBy(x: 0.0, y: -pageBounds.size.height)

      // Add the PDFPage to the PDFDocument
      pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)

      return pdfDocument
    }
    return nil
  }
}


class PDFCreator: NSObject {
    
  func create(from existingPDF: PDFDocument, observations: [VNRecognizedTextObservation], completion: (PDFDocument?) -> Void) {
        // Set up PDF renderer
        let renderer = UIGraphicsPDFRenderer(bounds: .zero)
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("output.pdf")
        
        // Render PDF pages
        let pdfData = renderer.pdfData { context in
            for observation in observations {
                let text = observation.topCandidates(1).first?.string ?? ""
                let point = observation.boundingBox.origin
                let font = UIFont.systemFont(ofSize: 12)
                let textColor = UIColor.black
                let attributes = [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.foregroundColor: textColor
                ]
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                let nsText = NSString(string: text)
                let size = nsText.size(withAttributes: attributes)
                
                // Draw text on PDF page
                let pageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                context.beginPage()
                attributedString.draw(in: pageRect.offsetBy(dx: point.x, dy: point.y))
              UIGraphicsEndPDFContext()
            }
        }
        
        // Create PDF document from rendered PDF data
        let pdfDocument = PDFDocument(data: pdfData)
        completion(pdfDocument)
    }
    
}


//func convertPDFPagesToImages(pdfDocument: PDFDocument) -> [UIImage] {
//  var images: [UIImage] = []
//
//  for i in 0..<pdfDocument.pageCount {
//    guard let page = pdfDocument.page(at: i) else {
//      continue
//    }
//    let thumbnailSize = CGSize(width: page.bounds(for: .cropBox).size.width * 2, height: page.bounds(for: .cropBox).size.height * 2)
//    UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 0.0)
//    guard let context = UIGraphicsGetCurrentContext() else {
//      continue
//    }
//    context.setFillColor(UIColor.white.cgColor)
//    context.fill(CGRect(origin: .zero, size: thumbnailSize))
//    context.saveGState()
//    context.translateBy(x: 0.0, y: thumbnailSize.height)
//    context.scaleBy(x: 1.0, y: -1.0)
//    page.draw(with: .cropBox, to: context)
//
//    context.restoreGState()
//    let image = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    if let image = image {
//      images.append(image)
//    }
//  }
//
//  return images
//}

//func convertPDFPagesToImages1(pdfDocument: PDFDocument) -> [UIImage] {
//  var images: [UIImage] = []
//  
//  for i in 0..<pdfDocument.pageCount {
//    guard let page = pdfDocument.page(at: i) else {
//      continue
//    }
//    let thumbnailSize = CGSize(width: page.bounds(for: .cropBox).size.width * 2, height: page.bounds(for: .cropBox).size.height * 2)
//    UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 0.0)
//    page.draw(with: .cropBox, to: UIGraphicsGetCurrentContext()!)
//    let image = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    if let image = image {
//      images.append(image)
//    }
//  }
//  
//  return images
//}
//
//func convertPDFPagesToImages2(pdfDocument: PDFDocument, forScale scale: Double = 2.0, completion: @escaping ([UIImage]) -> Void) {
//  DispatchQueue.global(qos: .userInitiated).async {
//    var images: [UIImage] = []
//    
//    for i in 0..<pdfDocument.pageCount {
//      guard let page = pdfDocument.page(at: i) else {
//        continue
//      }
//      let thumbnailSize = CGSize(width: page.bounds(for: .cropBox).size.width * scale,
//                                 height: page.bounds(for: .cropBox).size.height * scale)
//      UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 0.0)
//      page.draw(with: .cropBox, to: UIGraphicsGetCurrentContext()!)
//      let image = UIGraphicsGetImageFromCurrentImageContext()
//      UIGraphicsEndImageContext()
//      if let image = image {
//        images.append(image)
//      }
//    }
//    
//    DispatchQueue.main.async {
//      completion(images)
//    }
//  }
//}

//class ImageExtractionQueue: OperationQueue {
//
//    // Maximum number of concurrent image extraction operations
//    let maxConcurrentImageExtractions = 3
//
//    override init() {
//        super.init()
//        self.maxConcurrentOperationCount = maxConcurrentImageExtractions
//    }
//
//    // Add a new image extraction operation to the queue
//    func addImageExtractionOperation(forPage page: PDFPage, completion: @escaping (UIImage?, Error?) -> Void) {
//        let operation = ImageExtractionOperation(page: page)
//        operation.completionBlock = {
//            completion(operation.image, operation.error)
//        }
//        self.addOperation(operation)
//    }
//
//}
//
//class ImageExtractionOperation: Operation {
//
//    let page: PDFPage
//    var image: UIImage?
//    var error: Error?
//
//    init(page: PDFPage) {
//        self.page = page
//    }
//
//    override func main() {
//        // Extract the image from the PDF page
//        let thumbnailSize = CGSize(width: 200, height: 200)
//        guard let pageImage = page.thumbnail(of: thumbnailSize, for: .cropBox) else {
//            error = ImageExtractionError.imageExtractionFailed
//            return
//        }
//        image = pageImage
//    }
//
//}
//
//enum ImageExtractionError: Error {
//    case imageExtractionFailed
//}

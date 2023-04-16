//
//  PDFImageExtraction.swift
//  Sandwich
//
//  Created by Mister Grizzly on 16.04.2023.
//

import PDFKit
import UIKit

final class PDFImageExtraction {
  private class ImageExtractionOperationQueue: OperationQueue {
    override init() {
      super.init()
      self.maxConcurrentOperationCount = 2
    }
  }

  private class PDFImageExtractionOperation: Operation {
    private let document: PDFDocument
    
    var images: [UIImage] = []
    
    init(document: PDFDocument) {
      self.document = document
    }
    
    override func main() {
      guard !isCancelled else { return }
      
      // Extract images from each page in the PDF document
      for i in 0..<document.pageCount {
        guard !isCancelled else { return }
        
        if let page = document.page(at: i) {
          let size = CGSize(width: page.bounds(for: .cropBox).width * 2, height: page.bounds(for: .cropBox).height * 2)
          images.append(page.thumbnail(of: size, for: .cropBox))
        }
      }
    }
  }

  class func extractImagesFromPDFDocument(_ pdfDocument: PDFDocument, completion: @escaping ([UIImage]) -> Void) {
    let queue = ImageExtractionOperationQueue()
    
    // Create and add your PDF image extraction operation to the queue
    let operation = PDFImageExtractionOperation(document: pdfDocument)
    queue.addOperation(operation)
    
    // Set a completion block to be executed when the operation finishes
    operation.completionBlock = { //[weak self] in
      DispatchQueue.main.async {
        let images = operation.images
        // Use the extracted images as needed
        completion(images)
      }
    }
  }
  
  class func extractImagesFromPDFView(_ pdfView: PDFView, completion: @escaping ([UIImage]) -> Void) {
    guard let document = pdfView.document else {
      return completion([])
    }
    extractImagesFromPDFDocument(document, completion: completion)
  }
}

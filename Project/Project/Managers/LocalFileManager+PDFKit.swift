//
//  LocalFileManager+PDFKit.swift
//  Project
//
//  Created by Mister Grizzly on 07.04.2023.
//

import PDFKit

extension LocalFileManager {
  func generateThumbnail(for pdfURL: URL) -> UIImage? {
    guard let pdfDocument = PDFDocument(url: pdfURL) else {
      return nil
    }
    let pdfPage = pdfDocument.page(at: 0)
    let thumbnailSize = CGSize(width: 300, height: 200) // set your desired size here
    return pdfPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.mediaBox)
  }
}

extension UIImage {
  static func generateThumbnail(for pdfURL: URL) -> UIImage? {
    guard let pdfDocument = PDFDocument(url: pdfURL) else {
      return nil
    }
    let pdfPage = pdfDocument.page(at: 0)
    let thumbnailSize = CGSize(width: 300, height: 200) // set your desired size here
    return pdfPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.mediaBox)
  }
}

extension LocalFileManager {
  func mergePDF(urls: [URL], with name: String, toRootURL url: URL) {
    let fileManager = FileManager.default
    let fileURL = url.appendingPathComponent("\(name).pdf")
    
    // Create a new PDFDocument to hold the merged pages
    let validatedName = fileManager.validateFolderName(at: fileURL)
    let mergedDocument = PDFDocument()
    
    // Loop through each URL and add each page to the merged document
    for url in urls {
      guard let document = PDFDocument(url: url) else { continue }
      for pageIndex in 0..<document.pageCount {
        if let page = document.page(at: pageIndex) {
          mergedDocument.insert(page, at: mergedDocument.pageCount)
        }
      }
    }
    
    if let validatedName = validatedName {
      // Save the merged document to a file
      let outputURL = url.appendingPathComponent(validatedName)
      mergedDocument.write(to: outputURL)
    }
  }
}

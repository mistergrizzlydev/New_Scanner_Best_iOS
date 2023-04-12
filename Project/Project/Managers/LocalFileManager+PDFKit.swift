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

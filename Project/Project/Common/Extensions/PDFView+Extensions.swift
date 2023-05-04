import PDFKit
import UIKit

extension PDFView {
  func configure(displayDirection: PDFDisplayDirection = .horizontal, autoScales: Bool = true, displayMode: PDFDisplayMode = .singlePage) {
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.displayMode = displayMode
    self.displayDirection = displayDirection
    self.autoScales = autoScales
    usePageViewController(true, withViewOptions: [UIPageViewController.OptionsKey.interPageSpacing: 10])
    
    subviews.forEach { subview in
      if let scrollView = subview.subviews.first as? UIScrollView {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
      }
    }
  }
}

extension PDFView {
  var hasAnnotations: Bool {
    guard let document = document else { return false }
    for pageNumber in 0..<document.pageCount {
      if let page = document.page(at: pageNumber) {
        if !page.annotations.isEmpty {
          return true // This page has annotations, return true immediately
        }
      }
    }
    
    return false // No annotations found in any page
  }
}

extension PDFView {
  func removeAllAnnotations() {
    guard let document = document else { return }
    
    for pageNumber in 0..<document.pageCount {
      if let page = document.page(at: pageNumber) {
        page.removeAllAnnotations()
      }
    }
  }
}

extension PDFView {
  func refresh() {
    document?.reSave()
    // Refresh the PDF view to show the updated document
    displayMode = displayMode
  }
}

extension PDFView {
  func getText() -> String? {
    guard let pdfDocument = document else {
      return nil
    }
    
    var text = ""
    
    for pageIndex in 0..<pdfDocument.pageCount {
      guard let page = pdfDocument.page(at: pageIndex) else {
        continue
      }
      
      guard let pageContent = page.string else {
        continue
      }
      
      text += pageContent
    }
    
    return text
  }
}


extension PDFView {
  func firstPageImage() -> UIImage? {
    guard document?.pageCount != 0 else {
      return nil
    }
      
    if let firstPage = document?.page(at: 0) {
      let pageSize = firstPage.bounds(for: .mediaBox).size
      if let cgImage = firstPage.thumbnail(of: pageSize, for: .mediaBox).cgImage {
        return UIImage(cgImage: cgImage)
      }
    }
    
//    guard let page = self.document?.pageCount//page(at: 0) else {
//      return nil
//    }
//
//    let pageSize = page.bounds(for: .mediaBox)
//    let renderer = UIGraphicsImageRenderer(size: pageSize)
//    let image = renderer.image { context in
//      context.cgContext.interpolationQuality = .high
//      page.draw(with: .mediaBox, to: context.format.bounds)
//    }
//
//    return image
    
    return nil
  }
}

extension PDFView {
  //        guard let document = document else { return false }
  // document?.page(at: 0)?.pageRef?.getBoxRect(.cropBox) to extract image
  /*
   ▿ Optional<CGRect>
   ▿ some : (0.0, 0.0, 1190.0, 1684.0)
   ▿ origin : (0.0, 0.0)
   - x : 0.0
   - y : 0.0
   ▿ size : (1190.0, 1684.0)
   - width : 1190.0
   - height : 1684.0
   */
  
  var isSandwichPDF: Bool {
    document?.isSandwichPDF ?? false
  }
}

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
//    guard let documentURL = document?.documentURL else { return }
//    document?.write(to: documentURL, withOptions: [:])
    document?.reSave()
    
    // Refresh the PDF view to show the updated document
    displayMode = displayMode
  }
}

extension PDFPage {
  func removeAllAnnotations() {
    for annotation in annotations {
      removeAnnotation(annotation)
    }
  }
}

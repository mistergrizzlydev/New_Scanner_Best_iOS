import PDFKit

extension PDFPage {
  func removeAllAnnotations() {
    for annotation in annotations {
      removeAnnotation(annotation)
    }
  }
}

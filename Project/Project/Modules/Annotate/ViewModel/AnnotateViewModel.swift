import Foundation
import QuickLook

final class AnnotatePreviewItem: NSObject, QLPreviewItem {
  let previewItemURL: URL?
  let previewItemTitle: String?
  
  init(documentURL: URL?) {
    self.previewItemURL = documentURL
    self.previewItemTitle = documentURL?.pdfName
  }
}

struct AnnotateViewModel {
  let item: AnnotatePreviewItem
}

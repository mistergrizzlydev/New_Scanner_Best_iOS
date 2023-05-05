import UIKit
import PDFKit

protocol RearrangePresenterProtocol {
  func present()
  func updatePage(sourceIndex: Int, destinationIndex: Int)
}

final class RearrangePresenter: RearrangePresenterProtocol {
  private weak var view: (RearrangeViewControllerProtocol & UIViewController)!
  private let pdfDocument: PDFDoc
  
  init(view: RearrangeViewControllerProtocol & UIViewController, pdfDocument: PDFDoc) {
    self.view = view
    self.pdfDocument = pdfDocument
  }
  
  func present() {
    var viewModels = [RearrangeViewModel]()
    
    pdfDocument.getImages { [weak self] images in
      let sortedImages = images.sorted { $0.key < $1.key }
      for image in sortedImages {
        let deleteCompletion: ((RearrangeViewModel?) -> Void) = { viewModel in
          self?.onDelete(at: viewModel?.pageNumber)
        }
        let viewModel = RearrangeViewModel(image: image.value, pageNumber: "\(image.key + 1)", deleteCompletion: deleteCompletion)
        viewModels.append(viewModel)
      }
      
      self?.view.prepare(with: viewModels)
    }
  }
  
  @objc private func onDelete(at index: String?) {
    if let index = index, let indexToRemove = Int(index) {
     
      let removeIndex = indexToRemove - 1
      pdfDocument.removePage(at: removeIndex)
      if pdfDocument.pageCount == 0 {
        guard let documentURL = pdfDocument.documentURL else { return }
        try? FileManager.default.removeItem(at: documentURL)
        view.dismiss(animated: true) {
          NotificationCenter.default.post(name: .rearrangeScreenDeleteLastPage, object: nil)
        }
      } else {
        pdfDocument.reSave { [weak self] in
          NotificationCenter.default.post(name: .rearrangeScreenDeletePage, object: nil)
          self?.present()
        }
      }
    }
  }
  
  func updatePage(sourceIndex: Int, destinationIndex: Int) {
    guard sourceIndex != destinationIndex else { return } // No need to update if source and destination indices are the same
    pdfDocument.exchangePage(at: sourceIndex, withPageAt: destinationIndex) // Update the PDF document
    pdfDocument.reSave()
    present()
  }
}

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
        NotificationCenter.default.post(name: .rearrangeScreenDeletePage, object: nil)
        pdfDocument.reSave()
        present()
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

extension PDFDocument {
  func toImages(size: CGSize = CGSize(width: 150, height: 250)) -> [UIImage] {
    var images = [UIImage]()
    for pageNumber in 0..<self.pageCount {
      guard let page = self.page(at: pageNumber) else {
        continue
      }
      
      let image = UIImage(cgImage: page.thumbnail(of: size, for: .mediaBox).cgImage!)
      images.append(image)
    }
    
    return images
  }
}
extension PDFDocument {
  func getImages(size: CGSize = CGSize(width: 150, height: 250), completion: @escaping ([Int: UIImage]) -> Void) {
    var images = [Int: UIImage]()
    let queue = DispatchQueue(label: "pdfToImageQueue", qos: .userInitiated, attributes: .concurrent)
    let group = DispatchGroup()
    
    for pageNumber in 0..<self.pageCount {
      group.enter()
      queue.async {
        guard let page = self.page(at: pageNumber) else {
          group.leave()
          return
        }
        guard let cgImage = page.thumbnail(of: size, for: .artBox).cgImage else { return } // artBox // mediaBox
        let image = UIImage(cgImage: cgImage)
        images[pageNumber] = image
        group.leave()
      }
    }
    
    group.notify(queue: DispatchQueue.main) {
      completion(images)
    }
  }
}

extension PDFDocument {
  func reSave() {
    // Save the rearranged PDF document
    guard let documentURL = documentURL else { return }
    try? FileManager.default.removeItem(atPath: documentURL.pathExtension)
    
    do {
      try dataRepresentation()?.write(to: documentURL, options: .atomic)
    } catch {
      debugPrint("cannot save ", error.localizedDescription)
    }
  }
}


extension Notification.Name {
  static let rearrangeScreenDeletePage = Notification.Name("RearrangeScreenDeletePage")
  static let rearrangeScreenDeleteLastPage = Notification.Name("RearrangeScreenDeleteLastPage")
}

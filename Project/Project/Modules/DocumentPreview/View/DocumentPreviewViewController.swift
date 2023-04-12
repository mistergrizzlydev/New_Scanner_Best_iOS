import UIKit
import PDFKit

protocol DocumentPreviewViewControllerProtocol: AnyObject {
  func prepare(with viewModel: DocumentPreviewViewModel)
}

final class DocumentPreviewViewController: UIViewController, DocumentPreviewViewControllerProtocol {
  var presenter: DocumentPreviewPresenterProtocol!
  
  @IBOutlet private weak var pdfView: PDFView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    UIView.animate(withDuration: 0.3) {
      self.tabBarController?.tabBar.frame.origin.y = self.view.frame.maxY
      self.navigationController?.setToolbarHidden(false, animated: true)
      self.navigationController?.hidesBarsOnTap = true
    }
    
    if let toolbar = navigationController?.toolbar {
      navigationController?.toolbar.frame = CGRect(x: toolbar.frame.origin.x, y: toolbar.frame.origin.y, width: toolbar.frame.width, height: 44)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIView.animate(withDuration: 0.3) {
      self.tabBarController?.tabBar.frame.origin.y = self.view.frame.maxY - self.tabBarController!.tabBar.frame.height
      self.navigationController?.setToolbarHidden(true, animated: false)
      self.navigationController?.hidesBarsOnTap = false
    }
  }
  
  private func setupViews() {
    // Setup views
    
    pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    pdfView.displayMode = .singlePage
    pdfView.displayDirection = .horizontal
    pdfView.autoScales = true
    pdfView.usePageViewController(true, withViewOptions: [:])
    
    pdfView.subviews.forEach { subview in
      if let scrollView = subview.subviews.first as? UIScrollView {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
      }
    }
    
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    let addButton = UIBarButtonItem.barButtonItem(withImage: .systemPlus(), title: "Add", target: self, action: nil)
    let shareButton = UIBarButtonItem.barButtonItem(withImage: .systemShare(), title: "Share", target: self, action: nil)
    let annotateButton = UIBarButtonItem.barButtonItem(withImage: .systemAnnotate(), title: "Annotate", target: self, action: nil)
    let editButton = UIBarButtonItem.barButtonItem(withImage: .systemEdit(), title: "Edit", target: self, action: nil)
    let textButton = UIBarButtonItem.barButtonItem(withImage: .systemTextSearch(), title: "Text", target: self, action: nil)
    
    toolbarItems = [addButton, spacer, shareButton, spacer, annotateButton, spacer, editButton, spacer, textButton]
    navigationController?.toolbar.tintColor = UIColor.themeColor
  }
  
  func prepare(with viewModel: DocumentPreviewViewModel) {
    navigationItem.title = viewModel.title
    
    if let pdfDocument = PDFDocument(url: viewModel.file.url) {
      pdfView.document = pdfDocument
    }
    
    
//    let images = [UIImage(named: "invoice1")!, UIImage(named: "invoice2")!]
//    let sandwichPDFData = images.toPDF()!
//    do {
//      try sandwichPDFData.write(to: viewModel.file.url.deletingLastPathComponent().appendingPathComponent("example.pdf"))
//    } catch {
//      print(error.localizedDescription)
//    }
    
//    let newURL = viewModel.file.url.deletingLastPathComponent().appendingPathComponent("example.pdf")
//    let data = PDFManager.createSearchablePDF(from: UIImage(named: "invoice1")!)?.dataRepresentation()
//    //UIImage(named: "invoice1")?.testVision()?.dataRepresentation()
//
//    do {
//      try data?.write(to: newURL)
//    } catch {
//      print(error.localizedDescription)
//    }
    
    let image = UIImage(named: "invoice1")
//    image?.recognizeTextInImage()
    let newURL = viewModel.file.url.deletingLastPathComponent().appendingPathComponent("example.pdf")
//    let data = image?.tint(tintColor: .black.withAlphaComponent(0.2)).pdf?.dataRepresentation() // adds tint cool
//
//    do {
//      try data?.write(to: newURL, options: .atomic)
//    } catch {
//      print(error.localizedDescription)
//    }
    
//    image?.recognizeTextInImageAndDrawOnPDF2 { document in
//      do {
//        try document?.dataRepresentation()?.write(to: newURL, options: .atomic)
//      } catch {
//        print(error.localizedDescription)
//      }
//    }

//    guard let pdfDocument = image?.pdf else { return }
  
//    guard let page = pdfDocument.page(at: 0) else { return }
//    let renderer = UIGraphicsPDFRenderer(bounds: page.bounds(for: .cropBox))
//    let data = renderer.pdfData { context in
//        let font = UIFont.systemFont(ofSize: 20)
//        let textColor = UIColor.red
//        let attributes = [
//            NSAttributedString.Key.font: font,
//            NSAttributedString.Key.foregroundColor: textColor
//        ]
//        let text = "Hello, World!"
//        let point = CGPoint(x: 100, y: 100)
//        let nsText = NSString(string: text)
//        nsText.draw(at: point, withAttributes: attributes)
//    }
//
//    try? data.write(to: newURL, options: .atomic)
    
//    guard let page = pdfDocument.page(at: 0) else { return }
//    let bounds = page.bounds(for: .cropBox)
//    UIGraphicsPDFRenderer(bounds: bounds)
//    let text = "Hello, World!"
//    let point = CGPoint(x: 100, y: 100)
//    let font = UIFont.systemFont(ofSize: 12)
//    let textColor = UIColor.black
//    let attributes = [
//        NSAttributedString.Key.font: font,
//        NSAttributedString.Key.foregroundColor: textColor
//    ]
//    let nsText = NSString(string: text)
//    nsText.draw(at: point, withAttributes: attributes)
//
//    pdfDocument.write(to: newURL)

/*
 // works
 */
    /*
    guard let page = pdfDocument.page(at: 0) else { return }
    let bounds = page.bounds(for: .cropBox)
    UIGraphicsBeginPDFContextToFile(newURL.path, bounds, nil)
    UIGraphicsBeginPDFPage()
    let context = UIGraphicsGetCurrentContext()
    page.draw(with: .cropBox, to: context!)
    let text = "Hello, World!"
    let point = CGPoint(x: 100, y: 100)
    let font = UIFont.systemFont(ofSize: 12)
    let textColor = UIColor.black
    let attributes = [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: textColor
    ]
    let nsText = NSString(string: text)
    nsText.draw(at: point, withAttributes: attributes)
    UIGraphicsEndPDFContext()
*/
//    guard let page = pdfDocument.page(at: 0) else { return }
//    let bounds = page.bounds(for: .cropBox)
//    UIGraphicsBeginPDFContextToFile(newURL.path, bounds, nil)
//    UIGraphicsBeginPDFPage()
//    let context = UIGraphicsGetCurrentContext()
//    let rotationAngle = -page.rotation // calculate inverse rotation angle
//    context?.translateBy(x: 0.0, y: bounds.size.height) // move origin to bottom left
//    context?.scaleBy(x: 1.0, y: -1.0) // flip context vertically
//    context?.concatenate(page.transform(for: .artBox)) // apply inverse rotation transform
//    page.draw(with: .cropBox, to: context!)
//    let text = "Hello, World!"
//    let point = CGPoint(x: 100, y: 100)
//    let font = UIFont.systemFont(ofSize: 12)
//    let textColor = UIColor.black
//    let attributes = [    NSAttributedString.Key.font: font,    NSAttributedString.Key.foregroundColor: textColor]
//    let nsText = NSString(string: text)
//    nsText.draw(at: point, withAttributes: attributes)
//    UIGraphicsEndPDFContext()


    
    
//    let doc = image?.write(pdfDocument: pdf!, bounds: bounds)
//          do {
//            try doc?.dataRepresentation()?.write(to: newURL, options: .atomic)
//            drawText(in: newURL)
//          } catch {
//            print(error.localizedDescription)
//          }
  }
}

extension DocumentPreviewViewController {
  @objc private func printButtonTapped() {
    // handle print button tap
    
  }
  
  @objc private func bookmarkButtonTapped() {
    // handle bookmark button tap
    
  }
}

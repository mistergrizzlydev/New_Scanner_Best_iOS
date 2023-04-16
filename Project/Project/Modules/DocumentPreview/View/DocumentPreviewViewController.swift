import UIKit
import PDFKit
import MobileCoreServices
import UniformTypeIdentifiers

protocol DocumentPreviewViewControllerProtocol: AnyObject {
  func prepare(with viewModel: DocumentPreviewViewModel)
}

final class DocumentPreviewViewController: UIViewController, DocumentPreviewViewControllerProtocol {
  var presenter: DocumentPreviewPresenterProtocol!
  
  @IBOutlet private weak var pdfView: PDFView!
  private var viewModel: DocumentPreviewViewModel?
  
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
    pdfView.configure(displayDirection: .horizontal, displayMode: .singlePage)
    
    // if file locked: lock.doc.fill
    
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    let addButton = UIBarButtonItem(image: UIImage(systemName: "doc.badge.plus") /*.systemPlus()*/, style: .plain, target: self, action: nil)
    let shareButton = UIBarButtonItem(image: .systemShare(), style: .plain, target: self, action: #selector(onShareTapped(_:)))
    let annotateButton = UIBarButtonItem(image: .systemAnnotate(), style: .plain, target: self, action: #selector(onAnnotateTapped(_:)))
    let editButton = UIBarButtonItem(image: UIImage(systemName: "wand.and.stars")/*.systemEdit()*/, style: .plain, target: self, action: #selector(onEditTapped(_:)))
    let textButton = UIBarButtonItem(image: UIImage(systemName: "doc.plaintext") /*.systemTextSearch()*/, style: .plain, target: self, action: #selector(onTextTapped(_:)))
    
    let cameraAction = UIAction(title: "Camera", image: UIImage(systemName: "camera")) { _ in
      // handle camera action
    }
    
    let galleryAction = UIAction(title: "Gallery", image: UIImage(systemName: "photo")) { _ in
      // handle gallery action
    }
    
    let documentsAction = UIAction(title: "Documents", image: UIImage(systemName: "icloud")) { _ in
      self.presenter.onImportFileFromDocuments()
    }
    
    addButton.menu = UIMenu(title: "Import page from:", children: [documentsAction, galleryAction, cameraAction])
    
    
    toolbarItems = [addButton, spacer, shareButton, spacer, annotateButton, spacer, editButton, spacer, textButton]
    navigationController?.toolbar.tintColor = UIColor.themeColor
    
    let menuButton = UIBarButtonItem(image: .systemEllipsisCircle(), style: .plain, target: self, action: nil)
    //
    //    let section1 = UIMenu(title: "Create a new folder", options: .displayInline, children: [])
    //    let section2 = UIMenu(title: "Sort by:", options: .displayInline, children: [])
    //    let menu = UIMenu(options: .displayInline, children: [section1, section2])
    //    menuButton.menu = UIMenu.updateActionState(menu: menu)
    //    navigationItem.setRightBarButtonItems([menuButton], animated: true)
    
    
    let noAction = UIAction(title: "No") { _ in
      
    }
    let yesAction = UIAction(title: "Yes") { _ in
      
    }
    let menu = UIMenu(title: "", children: [noAction, yesAction])
    menuButton.menu = menu
    navigationItem.setRightBarButtonItems([menuButton], animated: true)
  }
  
  func prepare(with viewModel: DocumentPreviewViewModel) {
    self.viewModel = viewModel
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

extension DocumentPreviewViewController {
  @objc private func onAnnotateTapped(_ sender: UIBarButtonItem) {
    presenter.onSignatureTapped()
  }
  
  private func onAddFilesFromCameraTapped() {
    
  }
  
  private func onAddFilesFromGalleryTapped() {
    
  }
  
  @objc private func onShareTapped(_ sender: UIBarButtonItem) {
    presenter.onShareTapped()
  }
  
  @objc private func onEditTapped(_ sender: UIBarButtonItem) {
    
  }
  
  @objc private func onTextTapped(_ sender: UIBarButtonItem) {
    guard let file = viewModel?.file else { return }
    let controller = TextBuilder().buildViewController(file: file)!
    navigationController?.pushViewController(controller, animated: true)
//    let navigation = BaseNavigationController(rootViewController: controller)
//    navigation.modalPresentationStyle = .fullScreen
////    navigation.modalPresentationStyle = .fullScreen
//    present(navigation, animated: true)
  }
}

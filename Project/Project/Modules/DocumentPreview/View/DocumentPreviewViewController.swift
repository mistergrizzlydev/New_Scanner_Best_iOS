import UIKit
import PDFKit
import MobileCoreServices
import UniformTypeIdentifiers

protocol DocumentPreviewViewControllerProtocol: AnyObject {
  func prepare(with viewModel: DocumentPreviewViewModel)
}

final class DocumentPreviewViewController: UIViewController, DocumentPreviewViewControllerProtocol {
  var presenter: DocumentPreviewPresenterProtocol!
  
  @IBOutlet private weak var pageLabel: BorderLabel!
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
    
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationItem.largeTitleDisplayMode = .never
    
    UIView.animate(withDuration: 0.3) {
      self.tabBarController?.tabBar.frame.origin.y = self.view.frame.maxY
      self.navigationController?.setToolbarHidden(false, animated: true)
//      self.navigationController?.hidesBarsOnTap = true
    }
    
    if let toolbar = navigationController?.toolbar {
      navigationController?.toolbar.frame = CGRect(x: toolbar.frame.origin.x, y: toolbar.frame.origin.y, width: toolbar.frame.width, height: 44)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
    
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
    
    let cameraAction = UIAction(title: "Take Photo", image: UIImage(systemName: "camera")) { _ in
      // handle camera action
    }
    
    let galleryAction = UIAction(title: "Photo Library", image: UIImage(systemName: "photo.on.rectangle")) { _ in
      // handle gallery action
    }
    
    let documentsAction = UIAction(title: "Choose Files", image: UIImage(systemName: "folder")) { _ in
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
    
    
    let noAction = UIAction(title: "Move") { _ in
      
    }
    
    let yesAction = UIAction(title: "Delete", attributes: .destructive) { _ in
      
    }
    let menu = UIMenu(title: "", children: [noAction, yesAction])
    menuButton.menu = menu
    navigationItem.setRightBarButtonItems([menuButton], animated: true)
    
    setupPDFView()
  }
  
  private func setupPDFView() {
    // Add page changed listener
    NotificationCenter.default.addObserver(self, selector: #selector(didPageChange(_:)), name: Notification.Name.PDFViewPageChanged, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didPageChange(_:)), name: Notification.Name.PDFViewVisiblePagesChanged, object: nil)
  }
  
  func prepare(with viewModel: DocumentPreviewViewModel) {
    self.viewModel = viewModel
    navigationItem.title = viewModel.title
    
    if let pdfDocument = PDFDocument(url: viewModel.file.url) {
      pdfView.document = pdfDocument
    }
    
    pdfView.delegate = self
    
    updatePageLabel()
  }
  
  private func updatePageLabel() {
    let currentPage = pdfView.currentPage?.pageRef?.pageNumber ?? 0
    let pageCount = pdfView.document?.pageCount ?? 0
    pageLabel.text = "\(currentPage) of \(pageCount)"
  }
}

extension DocumentPreviewViewController: PDFViewDelegate {
  @objc private func didPageChange(_ notification: Notification) {
    updatePageLabel()
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
    guard let image = getCurrentPageImage() else { return }
    let scannerViewController = ImageScannerController(image: image, delegate: self)
    present(scannerViewController, animated: false)
  }
  
  @objc private func onTextTapped(_ sender: UIBarButtonItem) {
    guard let file = viewModel?.file else { return }
    let controller = TextBuilder().buildViewController(file: file)!
    navigationController?.pushViewController(controller, animated: true)
  }
}

extension DocumentPreviewViewController: ImageScannerControllerDelegate {
  func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
    presentAlert(message: error.localizedDescription, alerts: [UIAlertAction(title: "Ok", style: .default)])
  }
  
  func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
    scanner.dismiss(animated: false)
    let image = results.enhancedImage ?? results.croppedScan.image
    
    guard let currentPageNumber = pdfView.currentPage?.pageRef?.pageNumber, let newPage = PDFPage(image: image) else { return }
    
    if let pdfDocument = pdfView.document, let url = viewModel?.file.url {
      
      pdfDocument.removePage(at: currentPageNumber)
      pdfDocument.insert(newPage, at: currentPageNumber)
      pdfDocument.write(to: url)
      pdfView.document = nil
      pdfView.document = pdfDocument
      pdfView.layoutDocumentView()
    }
  }
  
  func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
    scanner.dismiss(animated: false)
  }
}

extension DocumentPreviewViewController {
  func getCurrentPageImage() -> UIImage? {
    guard let currentPageNumber = pdfView.currentPage?.pageRef?.pageNumber, let currentPage = pdfView.currentPage else { return nil }
    let imageRect = currentPage.bounds(for: .mediaBox)
    let image = UIImage(cgImage: currentPage.thumbnail(of: CGSize(width: imageRect.width, height: imageRect.height), for: .mediaBox).cgImage!)
    image.draw(in: imageRect)
    
    return image
  }
}

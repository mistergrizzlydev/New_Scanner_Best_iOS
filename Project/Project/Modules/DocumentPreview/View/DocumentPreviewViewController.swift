import UIKit
import PDFKit
import MobileCoreServices
import UniformTypeIdentifiers
import Sandwich

protocol DocumentPreviewViewControllerProtocol: AnyObject {
  func prepare(with viewModel: DocumentPreviewViewModel)
  func refreshPDFView()
}

final class DocumentPreviewViewController: UIViewController, DocumentPreviewViewControllerProtocol {
  var presenter: DocumentPreviewPresenterProtocol!
  
  @IBOutlet private weak var pageLabel: BorderLabel!
  @IBOutlet private weak var pdfView: PDFView!
  @IBOutlet private weak var moveButton: UIButton!
  @IBOutlet private weak var showCategoryButton: UIButton!
  
  private var viewModel: DocumentPreviewViewModel?

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
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
    pdfView.configure(displayDirection: .horizontal, displayMode: .singlePage)
    
    if let firstPageImage = pdfView.firstPageImage() {
      SandwichPDF.check(key: AppConfiguration.OCR.personalKey, image: firstPageImage) { [weak self] result, error in
        if let result = result, let smartCategory = DocumentClasifierCategory(rawValue: result.intValue), let name = self?.viewModel?.file.name {
          if UserDefaults.getSmartCategory(name: name) == nil {
            UserDefaults.setSmartCategory(smartCategory, name: name)
            self?.showCategoryButton.setTitle(smartCategory.name, for: .normal)
          } else {
            let category = UserDefaults.getSmartCategory(name: name) ?? UserDefaults.documentClasifierCategory
            self?.showCategoryButton.setTitle(category.name, for: .normal)
          }
        } else {
          self?.showCategoryButton.setTitle(UserDefaults.documentClasifierCategory.name, for: .normal)
        }
      }
    }
    // if file locked: lock.doc.fill
    
    moveButton.setTitle("Move to", for: .normal)
    let font = UIFont.systemFont(ofSize: 12, weight: .medium)
    let configuration = UIImage.SymbolConfiguration(font: font)
    let folder = UIImage(systemName: "folder", withConfiguration: configuration)
    moveButton.setImage(folder, for: .normal)
      
      let notificationCenter = NotificationCenter.default
      let queue = OperationQueue.main
      
      notificationCenter.addObserver(forName: .smartCategorySelected, object: nil, queue: queue) { [weak self] notification in
        guard let name = self?.viewModel?.file.name else { return }
        let category = UserDefaults.getSmartCategory(name: name) ?? UserDefaults.documentClasifierCategory
        self?.showCategoryButton.setTitle(category.name, for: .normal)
      }
      
    let showCategoryFont = UIFont.systemFont(ofSize: 8, weight: .medium)
    let showCategoryConfiguration = UIImage.SymbolConfiguration(font: showCategoryFont)
    let showCategoryImage = UIImage(systemName: "arrowtriangle.down.fill", withConfiguration: showCategoryConfiguration)
    showCategoryButton.setImage(showCategoryImage, for: .normal)
    
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    let addButton = UIBarButtonItem(image: UIImage(systemName: "doc.badge.plus") /*.systemPlus()*/, style: .plain, target: self, action: nil)
    let shareButton = UIBarButtonItem(image: .systemShare(), style: .plain, target: self, action: #selector(onShareTapped(_:)))
    let annotateButton = UIBarButtonItem(image: .systemAnnotate(), style: .plain, target: self, action: #selector(onAnnotateTapped(_:)))
    let editButton = UIBarButtonItem(image: UIImage(systemName: "wand.and.stars")/*.systemEdit()*/, style: .plain, target: self, action: #selector(onEditTapped(_:)))
    let textButton = UIBarButtonItem(image: UIImage(systemName: "doc.plaintext") /*.systemTextSearch()*/, style: .plain, target: self, action: #selector(onTextTapped(_:)))
    
    let cameraAction = UIAction(title: "Take Photo", image: UIImage(systemName: "camera")) { [weak self] _ in
      self?.presenter.onImportFileFromCamera()
    }
    
    let galleryAction = UIAction(title: "Photo Library", image: UIImage(systemName: "photo.on.rectangle")) { [weak self] _ in
      self?.presenter.onImportFileFromGallery()
    }
    
    let documentsAction = UIAction(title: "Choose Files", image: UIImage(systemName: "folder")) { _ in
      self.presenter.onImportFileFromDocuments()
    }
    
    addButton.menu = UIMenu(title: "Import page from:", children: [documentsAction, galleryAction, cameraAction])
    
    
    toolbarItems = [addButton, spacer, shareButton, spacer, annotateButton, spacer, editButton, spacer, textButton]
    navigationController?.toolbar.tintColor = UIColor.themeColor
    
    let menuButton = UIBarButtonItem(image: .systemEllipsisCircle(), style: .plain, target: self, action: nil)
    setMenu(to: menuButton)
    navigationItem.setRightBarButtonItems([menuButton], animated: true)
    
    setupPDFView()
  }
  
  private func setMenu(to menuButton: UIBarButtonItem) {
    let print = UIAction(title: "Print", image: UIImage(systemName: "printer")) { [weak self] _ in
      self?.presenter.printDocument()
    }

    let rearangePages = UIAction(title: "Rearrange pages", image: UIImage(systemName: "cursorarrow.and.square.on.square.dashed")) { [weak self] _ in
      self?.presenter.rearrange(with: self?.pdfView.document)
    }
    
    let removeAnnotations = UIAction(title: "Remove Annotations",
                                     image: UIImage(systemName: "pencil.tip.crop.circle.badge.minus"),
                                     attributes: .destructive) { [weak self] _ in
      self?.pdfView.removeAllAnnotations()
      self?.refreshPDFView()
      self?.showDrop(message: "Annotations removed", icon: UIImage(systemName: "pencil.tip.crop.circle.badge.minus"))
    }
    
    let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
      self.presenter.delete()
    }
    
    let children: [UIMenuElement] = pdfView.hasAnnotations ? [print, rearangePages, removeAnnotations, delete] : [print, rearangePages, delete]
    let menu = UIMenu(title: "", children: children)
    menuButton.menu = menu
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
      pdfView.delegate = self
      pdfView.enableDataDetectors = true
      debugPrint("isSandwichPDF ", pdfView.isSandwichPDF)
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
  
  @objc private func onShareTapped(_ sender: UIBarButtonItem) {
    presenter.onShareTapped(sender)
  }
  
  @objc private func onEditTapped(_ sender: UIBarButtonItem) {
    guard let currentPageNumber = pdfView.currentPage?.pageRef?.pageNumber, let currentPage = pdfView.currentPage else { return }
    let imageRect = currentPage.bounds(for: .mediaBox)
    let image = UIImage(cgImage: currentPage.thumbnail(of: CGSize(width: imageRect.width, height: imageRect.height), for: .mediaBox).cgImage!)
    image.draw(in: imageRect)
    presenter.onEditTapped(with: image, pageIndex: currentPageNumber)
  }
  
  @objc private func onTextTapped(_ sender: UIBarButtonItem) {
    guard let file = viewModel?.file/*, !pdfView.isSandwichPDF*/ else { return }
    let controller = TextBuilder().buildViewController(file: file)!
    navigationController?.pushViewController(controller, animated: true)
  }
}

extension DocumentPreviewViewController {
  func refreshPDFView() {
    let menuButton = UIBarButtonItem(image: .systemEllipsisCircle(), style: .plain, target: self, action: nil)
    setMenu(to: menuButton)
    navigationItem.setRightBarButtonItems([menuButton], animated: true)
    
    pdfView.refresh()
  }
}

extension DocumentPreviewViewController {
  @IBAction private func onMoveTapped(_ button: UIButton) {
    presenter.presentMove()
  }
  @IBAction private func onCategoryTapped(_ button: UIButton) {
    guard let file = viewModel?.file else { return }
    let controller = SmartCategoryBuilder().buildViewController(file: file)!
    //SmartCategoryCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    let navigation = BaseNavigationController(rootViewController: controller)
    if let sheet = navigation.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.prefersGrabberVisible = true
      //        sheet.smallestUndimmedDetentIdentifier = .medium
      sheet.prefersScrollingExpandsWhenScrolledToEdge = false
      //        sheet.preferredCornerRadius = 30.0
    }
    
    present(navigation, animated: true)
  }
}

extension DocumentPreviewViewController: PDFViewDelegate {
  @objc private func didPageChange(_ notification: Notification) {
    updatePageLabel()
  }
  
  func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
    
  }
  
  func pdfViewParentViewController() -> UIViewController {
    self
  }
  
  func pdfViewPerformFind(_ sender: PDFView) {
    
  }
  
  func pdfViewPerformGo(toPage sender: PDFView) {
    
  }
  
  func pdfViewOpenPDF(_ sender: PDFView, forRemoteGoToAction action: PDFActionRemoteGoTo) {
    
  }
}

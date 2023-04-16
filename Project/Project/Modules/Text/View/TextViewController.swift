import UIKit
import PDFKit
import Sandwich

protocol TextViewControllerProtocol: AnyObject {
  func prepare(with viewModel: TextViewModel)
}

final class TextViewController: UIViewController, TextViewControllerProtocol {
  private enum SegmentType: Int {
    case document = 0, text
    
    var title: String {
      switch self {
      case .document: return "Document"
      case .text: return "Text"
      }
    }
    
    static var allCases: [SegmentType] { [.document, .text] }
  }
  
  @IBOutlet private weak var textView: UITextView!
  @IBOutlet private weak var pdfView: PDFView!
  
  private var viewModel: TextViewModel?
  
  var presenter: TextPresenterProtocol!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }
  
  private func setupViews() {
    // Set up segment
    let items = SegmentType.allCases.map { $0.title }
    let segment = UISegmentedControl(items:items)
    segment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    segment.selectedSegmentIndex = SegmentType.document.rawValue
    navigationItem.titleView = segment
    
    pdfView.configure(displayDirection: .vertical, displayMode: .singlePage)
    
    textView.text = nil
  }
  
  func prepare(with viewModel: TextViewModel) {
    self.viewModel = viewModel
    pdfView.document = PDFDocument(url: viewModel.file.url)
    let personalKey = "K6THam-YqqTcU-WTWSde-qaayNa-cDqMLc-gLH"
    navigationItem.title = viewModel.file.name
    title = viewModel.file.name

    SandwichPDF.extractImagesFromPDFView(key: personalKey, pdfView: pdfView) { [weak self] success in
      
      if success {
//        DispatchQueue.main.async {
//          self?.showSuccess()
//        }
        self?.pdfView.document = PDFDocument(url: viewModel.file.url)
        self?.showSuccess()
        
        self?.textView.text = self?.pdfView.getText()
      }
    }
  }
  
  private func showSuccess() {
    guard let viewModel = viewModel else { return }
    let message = "PDF converted successfully to sandwich."
    showDrop(message: message, icon: .systemTextSearch())
  }
  
  @objc private func segmentChanged(_ sender: UISegmentedControl) {
    guard let segmentType = SegmentType(rawValue: sender.selectedSegmentIndex) else { return }
    switch segmentType {
    case .document:
      pdfView.isHidden = false
      textView.isHidden = true
    case .text:
      pdfView.isHidden = true
      textView.isHidden = false
    }
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

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
    
    navigationController?.isToolbarHidden = false
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    //    let printButton = UIBarButtonItem(image: UIImage(systemName: "printer"), style: .plain, target: self, action: #selector(printButtonTapped))
    //    printButton.title = "Print"
    //
    //    let bookmarkButton = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(bookmarkButtonTapped))
    //    bookmarkButton.title = "Bookmark"
    
    //    toolbarItems = [printButton, spacer, bookmarkButton]
    //    navigationController?.toolbar.tintColor = UIColor.black
    
    
    let bookmarkButton = UIBarButtonItem.barButtonItem(withImage: UIImage(systemName: "bookmark"), title: "Bookmark", target: self, action: nil)
    let printButton = UIBarButtonItem.barButtonItem(withImage: UIImage(systemName: "printer"), title: "Print", target: self, action: nil)
    toolbarItems = [printButton, spacer, bookmarkButton]
    navigationController?.toolbar.tintColor = UIColor.black
  }
  
  func prepare(with viewModel: DocumentPreviewViewModel) {
    navigationItem.title = viewModel.title
    
    if let pdfDocument = PDFDocument(url: viewModel.file.url) {
      pdfView.document = pdfDocument
    }
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

class CustomBarButtonItem: UIBarButtonItem {
  convenience init(image: UIImage?, title: String?, target: Any?, action: Selector?) {
    let button = CenteredButton(type: .system)
    button.setImage(image, for: .normal)
    button.setTitle(title, for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.setTitleColor(.lightGray, for: .highlighted)
    self.init(customView: button)
    self.target = target as AnyObject?
    self.action = action
  }
}

extension UIBarButtonItem {
  static func barButtonItem(withImage image: UIImage?, title: String?, target: Any?, action: Selector?) -> UIBarButtonItem {
    return CustomBarButtonItem(image: image, title: title, target: target, action: action)
  }
}


class CenteredButton: UIButton {
  let five: CGFloat = 10.0
  
  let padding: CGFloat = 6.0
   
   override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
       let area = bounds.insetBy(dx: -padding, dy: -padding)
       return area.contains(point)
   }
  
  override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
    let rect = super.titleRect(forContentRect: contentRect)
    
    return CGRect(x: 0, y: contentRect.height - rect.height + five,
                  width: contentRect.width, height: rect.height)
  }
  
  override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
    let rect = super.imageRect(forContentRect: contentRect)
    let titleRect = self.titleRect(forContentRect: contentRect)
    
    return CGRect(x: contentRect.width/2.0 - rect.width/2.0,
                  y: (contentRect.height - titleRect.height)/2.0 - rect.height/2.0,
                  width: rect.width, height: rect.height)
  }
  
  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    
    if let image = imageView?.image {
      var labelHeight: CGFloat = 0.0
      
      if let size = titleLabel?.sizeThatFits(CGSize(width: self.contentRect(forBounds: self.bounds).width,
                                                    height: CGFloat.greatestFiniteMagnitude)) {
        labelHeight = size.height
      }
      
      return CGSize(width: size.width, height: image.size.height + labelHeight + five)
    }
    
    return size
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    centerTitleLabel()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    centerTitleLabel()
  }
  
  private func centerTitleLabel() {
    self.titleLabel?.textAlignment = .center
  }
}

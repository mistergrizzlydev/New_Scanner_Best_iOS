import UIKit
import Sandwich

protocol DocNameViewControllerProtocol: AnyObject {
  func prepare(with viewModel: DocNameViewModel)
}

final class DocNameViewController: UIViewController, DocNameViewControllerProtocol {
  @IBOutlet private weak var tagsField: TextFieldTagsField!
  @IBOutlet private weak var palceHolderLabel: UILabel!
  
  var presenter: DocNamePresenterProtocol!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tagsField.beginEditing()
  }
  
  private func setupViews() {
    let suggestions = Tag.allCases.compactMap { $0.name }
    //["Day", "Month", "Year", "Date", "Time", "Seconds", "Invoice", "Scan"]
    
    //        button.setTitleColor(.bgColor, for: .normal)
    //        button.backgroundColor = .themeGreen
    
    tagsField.suggestions = suggestions
    tagsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
    tagsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    tagsField.spaceBetweenLines = 5.0
    tagsField.spaceBetweenTags = 10.0
    tagsField.font = .systemFont(ofSize: 17.0)
    tagsField.backgroundColor = .systemGray5
    tagsField.restrictTyping = true
    
    tagsField.cornerRadius = 8
    
    tagsField.tintColor = .themeGreen
    tagsField.textColor = .bgColor
    tagsField.textField.textColor = .blue
    tagsField.selectedColor = .black
    tagsField.selectedTextColor = .red
    tagsField.delimiter = ""
    tagsField.isDelimiterVisible = true
    tagsField.placeholderColor = .black.withAlphaComponent(0.7)
    tagsField.placeholderAlwaysVisible = true
    tagsField.keyboardAppearance = .dark
    tagsField.textField.returnKeyType = .done
    tagsField.acceptTagOption = .comma
    tagsField.shouldTokenizeAfterResigningFirstResponder = true
    tagsField.placeholder = ""
    
    let horizontalScrollView = HorizontalButtonScrollView(with: suggestions)
    horizontalScrollView.backgroundColor = .themeLigthGray
    
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    toolbar.addSubview(horizontalScrollView)
    horizontalScrollView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      horizontalScrollView.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor),
      horizontalScrollView.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
      horizontalScrollView.topAnchor.constraint(equalTo: toolbar.topAnchor),
      horizontalScrollView.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor)
    ])
    
    horizontalScrollView.onButtonTapped = { [weak self] title in
      self?.tagsField.addTag(title)
    }
    
    tagsField.textField.inputAccessoryView = toolbar
    palceHolderLabel.text = ""
    
    if UserDefaults.standard.selectedTags.isEmpty {
//      tagsField.addTags([""])
      UserDefaults.standard.selectedTags = [.invoice, .date]
    }
    
    tagsField.addTags(UserDefaults.standard.selectedTags.compactMap { $0.name })
    palceHolderLabel.text = Tag.convertToDate(from: UserDefaults.standard.selectedTags)
    
//    var selectedTags: [Tag] = UserDefaults.standard.selectedTags
//    var selectedTags: Set<Tag> = Set([])
    
    
    // Events
    tagsField.onDidAddTag = { [weak self] field, tag in
      guard let self = self else { return }
      print("DidAddTag", tag.text)
      
      guard let palceHolderLabel = self.palceHolderLabel, let tag = Tag(rawValue: tag.text.lowercased()), !UserDefaults.standard.selectedTags.contains(tag) else { return }
      UserDefaults.standard.selectedTags.insert(tag) //append(tag)
      palceHolderLabel.text = Tag.convertToDate(from: UserDefaults.standard.selectedTags)
    }
    
    tagsField.onDidRemoveTag = { field, tag in
      print("DidRemoveTag", tag.text)
      horizontalScrollView.addTag(tag.text)
      
      guard let palceHolderLabel = self.palceHolderLabel, let tag = Tag(rawValue: tag.text.lowercased()), UserDefaults.standard.selectedTags.contains(tag) else { return }
      print(UserDefaults.standard.selectedTags.count, UserDefaults.standard.selectedTags, tag)
      UserDefaults.standard.selectedTags.remove(tag)
      palceHolderLabel.text = Tag.convertToDate(from: UserDefaults.standard.selectedTags)
    }
    
    tagsField.onDidChangeText = { _, text in
      print("DidChangeText")
      //            guard let text = text, let tag = Tag(rawValue: text.lowercased()) else { return }
      //            self.palceHolderLabel.text = tag.name
    }
    
    tagsField.onDidChangeHeightTo = { _, height in
      print("HeightTo", height)
    }
    
    //        tagsField.onValidateTag = { tag, tags in
    //            // custom validations, called before tag is added to tags list
    //            return tag.text != "#" && !tags.contains(where: { $0.text.uppercased() == tag.text.uppercased() })
    //        }
    
    print("List of Tags Strings:", tagsField.tags.map({$0.text}))
  }
  
  func prepare(with viewModel: DocNameViewModel) {
    
  }
}

extension Array where Element == Tag {
  
  mutating func insert(_ tag: Tag) {
    if !contains(tag) {
      append(tag)
    }
  }
  
  mutating func remove(_ tag: Tag) {
    if let index = firstIndex(of: tag) {
      remove(at: index)
    }
  }
  
}


class HorizontalButtonScrollView: UIView {
  
  private let scrollView = UIScrollView()
  private let stackView = UIStackView()
  private let words: [String]
  
  var onButtonTapped: ((String) -> Void)?
  
  init(with words: [String]) {
    self.words = words
    super.init(frame: .zero)
    
    addSubview(scrollView)
    scrollView.addSubview(stackView)
    stackView.axis = .horizontal
    stackView.spacing = 12
    
    for word in words {
      let button = AutoAddPaddingButtton(type: .system)
      button.setTitle(word, for: .normal)
      button.setTitleColor(.bgColor, for: .normal)
      button.backgroundColor = .themeGreen
      button.layer.cornerRadius = 12
      button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
      button.sizeToFit()
      stackView.addArrangedSubview(button)
    }
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 5),
      stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
      stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 10),
      stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 5)
    ])
  }
  
  func addTag(_ word: String) {
    let button = AutoAddPaddingButtton(type: .system)
    button.setTitle(word, for: .normal)
    button.setTitleColor(.bgColor, for: .normal)
    button.backgroundColor = .themeGreen
    button.layer.cornerRadius = 12
    button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    button.sizeToFit()
    stackView.addArrangedSubview(button)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func buttonTapped(_ sender: UIButton) {
    let title = sender.titleLabel?.text ?? ""
    sender.removeFromSuperview()
    stackView.layoutSubviews()
    onButtonTapped?(title)
  }
}

class AutoAddPaddingButtton: UIButton {
  override var intrinsicContentSize: CGSize {
    get {
      let baseSize = super.intrinsicContentSize
      return CGSize(width: baseSize.width + 20, height: baseSize.height)
    }
  }
}

enum Tag: String, Decodable, Encodable {
  case day, month, year, date, time, seconds, invoice, scan
  
  var name: String {
    rawValue.capitalized
  }
  
  // "MMM dd yyyy, hh:mm:s a"
  //    var component: String {
  //        switch self {
  //        case .day:
  //            return "dd"
  //        case .month:
  //            return "MMM"
  //        case .year:
  //            return "yyyy"
  //        case .date:
  //            return "Date"
  //        case .time:
  //            return "hh:mm"
  //        case .seconds:
  //            return "ss"
  //        case .invoice:
  //            return "Invoice"
  //        case .scan:
  //            return "Scan"
  //        }
  //    }
  var component: String {
    switch self {
    case .day:
      return "dd"
    case .month:
      return "MM"
    case .year:
      return "yyyy"
    case .date:
      return "MMM dd yyyy, hh:mm:ss a"
    case .time:
      return "hh:mm a"
    case .seconds:
      return "ss"
    case .invoice:
      return "'Invoice'"
    case .scan:
      return "'Scan'"
    }
  }
  
  static var allCases: [Tag] = [.day, .month, .year, .date, .time, .seconds, .invoice, .scan]
  
  static func convertToDate(from tags: [Tag]) -> String {
    print("convert", tags.count, tags)
    let formatter = DateFormatter()
    var dateFormat = ""
    for tag in tags {
      dateFormat += tag.component
      if tag != tags.last {
        dateFormat += "-"
      }
    }
    
    formatter.dateFormat = dateFormat
    return formatter.string(from: Date())
  }
}

func toDate() -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "MMM dd yyyy, hh:mm:s a"
  let dateString = formatter.string(from: Date())
  let fileName = "Scan \(dateString)"
  return fileName
}

//extension UserDefaults {
//
//  var selectedTags: [Tag] {
//    get {
//      if let data = data(forKey: "selectedTags") {
//        do {
//          let decoder = JSONDecoder()
//          return try decoder.decode([Tag].self, from: data)
//        } catch {
//          print("Error decoding tags:", error)
//        }
//      }
//      return []
//    }
//    set {
//      do {
//        let encoder = JSONEncoder()
//        let data = try encoder.encode(newValue)
//        set(data, forKey: "selectedTags")
//      } catch {
//        print("Error encoding tags:", error)
//      }
//    }
//  }
//
//}

extension UserDefaults {
  var selectedTags: [Tag] {
    get {
      if let data = data(forKey: "selectedTags") {
        do {
          let decoder = JSONDecoder()
          return try decoder.decode([Tag].self, from: data)
        } catch {
          print("Error decoding tags:", error)
        }
      }
      return []
    }
    set {
      do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(newValue)
        set(data, forKey: "selectedTags")
      } catch {
        print("Error encoding tags:", error)
      }
    }
  }
}

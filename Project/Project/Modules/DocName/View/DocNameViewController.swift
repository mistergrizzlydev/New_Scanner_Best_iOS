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

    tagsField.addTags(UserDefaults.standard.selectedTags.compactMap { $0.name })
    palceHolderLabel.text = Tag.convertToDate(from: UserDefaults.standard.selectedTags)
    
    // Events
    tagsField.onDidAddTag = { [weak self] field, tag in
      guard let self = self else { return }
      debugPrint("DidAddTag", tag.text)
      
      guard let palceHolderLabel = self.palceHolderLabel, let tag = Tag(rawValue: tag.text.lowercased()), !UserDefaults.standard.selectedTags.contains(tag) else { return }
      UserDefaults.standard.selectedTags.insert(tag) //append(tag)
      palceHolderLabel.text = Tag.convertToDate(from: UserDefaults.standard.selectedTags)
    }
    
    tagsField.onDidRemoveTag = { field, tag in
      debugPrint("DidRemoveTag", tag.text)
      horizontalScrollView.addTag(tag.text)
      
      guard let palceHolderLabel = self.palceHolderLabel, let tag = Tag(rawValue: tag.text.lowercased()), UserDefaults.standard.selectedTags.contains(tag) else { return }
      debugPrint(UserDefaults.standard.selectedTags.count, UserDefaults.standard.selectedTags, tag)
      UserDefaults.standard.selectedTags.remove(tag)
      palceHolderLabel.text = Tag.convertToDate(from: UserDefaults.standard.selectedTags)
    }
    
    tagsField.onDidChangeText = { _, text in
      debugPrint("DidChangeText")
      //            guard let text = text, let tag = Tag(rawValue: text.lowercased()) else { return }
      //            self.palceHolderLabel.text = tag.name
    }
    
    tagsField.onDidChangeHeightTo = { _, height in
      debugPrint("HeightTo", height)
    }
    
    debugPrint("List of Tags Strings:", tagsField.tags.map({$0.text}))
  }
  
  func prepare(with viewModel: DocNameViewModel) {
    
  }
}

extension UserDefaults {
  var selectedTags: [Tag] {
    get {
      if let data = data(forKey: "557b4d7f-1025-4eb2-894b-9029648406c1") {
        do {
          let decoder = JSONDecoder()
          return try decoder.decode([Tag].self, from: data)
        } catch {
          debugPrint("Error decoding tags:", error)
        }
      }
      return []
    }
    set {
      do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(newValue)
        set(data, forKey: "557b4d7f-1025-4eb2-894b-9029648406c1")
      } catch {
        debugPrint("Error encoding tags:", error)
      }
    }
  }
}

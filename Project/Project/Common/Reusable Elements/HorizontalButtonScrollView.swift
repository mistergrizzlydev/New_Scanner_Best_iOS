import UIKit

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

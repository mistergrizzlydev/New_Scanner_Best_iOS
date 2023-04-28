import UIKit

final class FloatingStackView: UIStackView {
  private let cameraButton = UIButton(type: .system)
  private let galleryButton = UIButton(type: .system)
  private let separatorView = UIView()
  
  var cameraButtonTapped: (() -> Void)?
  var galleryButtonTapped: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupButtons()
    setupSeparatorView()
    setupStackView()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupButtons() {
    backgroundColor = .themeGreen
    layer.cornerRadius = 10
    clipsToBounds = true
    
    cameraButton.tintColor = .themeBlick
    cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
    cameraButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
    cameraButton.addTarget(self, action: #selector(cameraButtonAction), for: .touchUpInside)
    
    galleryButton.tintColor = .themeBlick
    galleryButton.setImage(UIImage(systemName: "photo.fill"), for: .normal)
    galleryButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
    galleryButton.addTarget(self, action: #selector(galleryButtonAction), for: .touchUpInside)
  }
  
  private func setupSeparatorView() {
    separatorView.backgroundColor = .lightGray.withAlphaComponent(0.6)
    separatorView.widthAnchor.constraint(equalToConstant: 0.8).isActive = true
  }
  
  private func setupStackView() {
    axis = .horizontal    
    addArrangedSubview(cameraButton)
    addArrangedSubview(separatorView)
    addArrangedSubview(galleryButton)
  }
  
  @objc private func cameraButtonAction() {
    cameraButtonTapped?()
  }
  
  @objc private func galleryButtonAction() {
    galleryButtonTapped?()
  }
}


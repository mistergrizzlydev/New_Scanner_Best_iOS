import UIKit
import Sandwich

protocol OCRLanguagesPresenterProtocol {
  func present()
  func toggleLanguages()
}

class OCRLanguagesPresenter: OCRLanguagesPresenterProtocol {
  private weak var view: (OCRLanguagesViewControllerProtocol & UIViewController)!
  
  init(view: OCRLanguagesViewControllerProtocol & UIViewController) {
    self.view = view
  }

  func present() {
    let languages = LatinLanguage.allCases.filter { $0.flag != nil }
    let viewModel = OCRLanguagesViewModel(title: "OCR Languages", languages: languages, isOn: UserDefaults.isOCREnabled)
    view.prepare(with: viewModel)
  }
  
  func toggleLanguages() {
    UserDefaults.isOCREnabled.toggle()
    present()
    NotificationCenter.default.post(name: .selectableScreenDidSelectOption, object: nil)
  }
}

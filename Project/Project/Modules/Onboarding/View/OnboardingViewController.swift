import UIKit

protocol OnboardingViewControllerProtocol: AnyObject {
  func prepare(with viewModel: OnboardingViewModel)
}

final class OnboardingViewController: UIViewController, OnboardingViewControllerProtocol {
  private struct Constants {
    
  }
  
  var presenter: OnboardingPresenterProtocol!
  
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var pickerView: UIPickerView!
  
  @IBOutlet private weak var doneButton: UIButton!
  @IBOutlet private weak var skipButton: UIButton!
  
  private var viewModel: OnboardingViewModel?
  private var category: OnboardingCategory?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    presenter.present()
    setupViews()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    titleLabel.showAndChangeTransformBack(delay: 0)
    pickerView.showAndChangeTransformBack(delay: 0.1)
    skipButton.showAndChangeTransformBack(delay: 0.2, alpha: 0.7)
  }
  
  private func setupViews() {
    // Setup views
    skipButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .light)
    
    doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .light)
    doneButton.setTitleColor(.white, for: UIControl.State())
    doneButton.backgroundColor = .brown
    doneButton.layer.cornerRadius = 8
    doneButton.clipsToBounds = true
    
    skipButton.transformAndHide()
    doneButton.transformAndHide()
    pickerView.transformAndHide()
    titleLabel.transformAndHide()
  }
  
  func prepare(with viewModel: OnboardingViewModel) {
    titleLabel.text = viewModel.title
    self.viewModel = viewModel
    
    pickerView.dataSource = self
    pickerView.delegate = self
    
    skipButton.setTitle(viewModel.skip, for: UIControl.State())
    doneButton.setTitle(viewModel.done, for: UIControl.State())
  }
  
  @IBAction private func onSkipTapped(_ sender: UIButton) {
    presenter.onCategoryTapped(.skip)
  }
  
  @IBAction private func onDoneTapped(_ sender: UIButton) {
    guard let category = category else { return }
    presenter.onCategoryTapped(category)
  }
}

extension OnboardingViewController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return viewModel?.categories.count ?? 0
  }
}

extension OnboardingViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return viewModel?.categories[row].name
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    guard let category = viewModel?.categories[row] else { return }
    if category != .skip, doneButton.alpha == 0 {
      doneButton.showAndChangeTransformBack(delay: 0.2)
    }
    self.category = category
  }
  
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    guard let title = viewModel?.categories[row].name else { return UIView() }
    
    var label = UILabel()
    if let v = view as? UILabel { label = v }
    label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    label.text = title
    label.textAlignment = .center
    let isSkip = viewModel?.categories[row] == .skip
    label.alpha = isSkip ? 0.6 : 1.0
    return label
  }
}

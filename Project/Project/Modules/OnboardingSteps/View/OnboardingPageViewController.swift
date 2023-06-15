//
//  OnboardingPage.swift
//  Project
//
//  Created by Mister Grizzly on 07.06.2023.
//

//import UIKit
//
//final class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
//
//  // Titles for each onboarding page
//  let titles = ["1", "2", "3"]
//  private var isSkipButtonHidden = false
//  private var skipButton: UIButton?
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//
//    // Set the delegate and data source
//    self.delegate = self
//    self.dataSource = self
//
//    // Create the first onboarding page
//    if let firstViewController = getViewController(atIndex: 0) {
//      setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
//    }
//
//    let startButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
//    startButton.center = CGPoint(x: view.center.x, y: view.center.y + 50)
//    startButton.setTitle("Start Now", for: .normal)
//    startButton.setTitleColor(UIColor.blue, for: .normal)
//    startButton.addTarget(self, action: #selector(startButtonTapped(_:)), for: .touchUpInside)
//    view.addSubview(startButton)
//
//    skipButton = UIButton(frame: CGRect(x: view.bounds.width - 80, y: 30, width: 80, height: 30))
//    skipButton?.setTitle("Skip", for: .normal)
//    skipButton?.setTitleColor(UIColor.blue, for: .normal)
//    skipButton?.isHidden = isSkipButtonHidden
//    skipButton?.addTarget(self, action: #selector(skipButtonTapped(_:)), for: .touchUpInside)
//    view.addSubview(skipButton!)
//  }
//
//  // MARK: - UIPageViewControllerDataSource
//
//  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//    if let index = titles.firstIndex(of: viewController.title ?? ""), index > 0 {
//      return getViewController(atIndex: index - 1)
//    }
//    return nil
//  }
//
//  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//    if let index = titles.firstIndex(of: viewController.title ?? ""), index < titles.count - 1 {
//      return getViewController(atIndex: index + 1)
//    }
//    return nil
//  }
//
//  // MARK: - Helper Methods
//
//  func getViewController(atIndex index: Int) -> UIViewController? {
//    if index < 0 || index >= titles.count {
//      return nil
//    }
//
//    let viewController = UIViewController()
//    viewController.title = titles[index]
//    viewController.view.backgroundColor = UIColor.white
//
//    let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
//    titleLabel.center = viewController.view.center
//    titleLabel.text = titles[index]
//    titleLabel.textAlignment = .center
//    viewController.view.addSubview(titleLabel)
//
//    if index <= 2 {
//      isSkipButtonHidden = true
//      skipButton?.isHidden = isSkipButtonHidden
//    } else if index == 2 {
////    if index < 2 {
////      isSkipButtonHidden = true
////      skipButton?.isHidden = isSkipButtonHidden
//    } else {
//
//      isSkipButtonHidden = false
//      skipButton?.isHidden = isSkipButtonHidden
//    }
//
//    return viewController
//  }
//
//  // MARK: - Button Actions
//
//  @objc func startButtonTapped(_ sender: UIButton) {
//    if let currentViewController = viewControllers?.first,
//       let nextViewController = pageViewController(self, viewControllerAfter: currentViewController) {
//      setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
//    }
//  }
//
//  @objc func skipButtonTapped(_ sender: UIButton) {
//    // Handle skip button action
//  }
//}

//
//  OnboardPage.swift
//  OnboardKit
//

import Foundation

public typealias OnboardPageCompletion = ((_ success: Bool, _ error: Error?) -> Void)
public typealias OnboardPageAction = (@escaping OnboardPageCompletion) -> Void

public struct OnboardPage {
  /// The title text used for the top label of the onboarding page
  let title: String

  /// An optional image to be used in the onboarding page
  ///
  /// - note: If no image is used, the description label will adjust fill the empty space
  let imageName: String?

  /// An optional description text to be used underneath the image
  ///
  /// - note: If no description text is used, the image will adjust fill the empty space
  let description: String?

  /// The title text to be used for the secondary button that is used to advance to the next page
  let advanceButtonTitle: String

  /// The title text to be used for the optional action button on the page
  ///
  /// - note: If no action button title is set, the button will not appear
  let actionButtonTitle: String?

  /// The action to be called when tapping the action button on the page
  ///
  /// - note: calling the completion on the action will advance the onboarding to the next page
  let action: OnboardPageAction?

  public init(title: String,
              imageName: String? = nil,
              description: String?,
              advanceButtonTitle: String = NSLocalizedString("Next", comment: ""),
              actionButtonTitle: String? = nil,
              action: OnboardPageAction? = nil) {
    self.title = title
    self.imageName = imageName
    self.description = description
    self.advanceButtonTitle = advanceButtonTitle
    self.actionButtonTitle = actionButtonTitle
    self.action = action
  }
}


import UIKit

internal protocol OnboardPageViewControllerDelegate: class {

  /// Informs the `delegate` that the action button was tapped
  ///
  /// - Parameters:
  ///   - pageVC: The `OnboardPageViewController` object
  ///   - index: The page index
  func pageViewController(_ pageVC: OnboardPageViewController, actionTappedAt index: Int)

  /// Informs the `delegate` that the advance(next) button was tapped
  ///
  /// - Parameters:
  ///   - pageVC: The `OnboardPageViewController` object
  ///   - index: The page index
  func pageViewController(_ pageVC: OnboardPageViewController, advanceTappedAt index: Int)
}

internal final class OnboardPageViewController: UIViewController {

  private lazy var pageStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 16.0
    stackView.axis = .vertical
    stackView.alignment = .center
    return stackView
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.preferredFont(forTextStyle: .title1)
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()

  private lazy var descriptionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.preferredFont(forTextStyle: .title3)
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()

  private lazy var actionButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
    return button
  }()

  private lazy var advanceButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
    return button
  }()

  let pageIndex: Int

  weak var delegate: OnboardPageViewControllerDelegate?

  private let appearanceConfiguration: OnboardViewController.AppearanceConfiguration

  init(pageIndex: Int, appearanceConfiguration: OnboardViewController.AppearanceConfiguration) {
    self.pageIndex = pageIndex
    self.appearanceConfiguration = appearanceConfiguration
    super.init(nibName: nil, bundle: nil)
    customizeStyleWith(appearanceConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func customizeStyleWith(_ appearanceConfiguration: OnboardViewController.AppearanceConfiguration) {
    view.backgroundColor = appearanceConfiguration.backgroundColor
    // Setup imageView
    imageView.contentMode = appearanceConfiguration.imageContentMode
    // Style title
    titleLabel.textColor = appearanceConfiguration.titleColor
    titleLabel.font = appearanceConfiguration.titleFont
    // Style description
    descriptionLabel.textColor = appearanceConfiguration.textColor
    descriptionLabel.font = appearanceConfiguration.textFont
  }

  private func customizeButtonsWith(_ appearanceConfiguration: OnboardViewController.AppearanceConfiguration) {
    advanceButton.sizeToFit()
    if let advanceButtonStyling = appearanceConfiguration.advanceButtonStyling {
      advanceButtonStyling(advanceButton)
    } else {
      advanceButton.setTitleColor(appearanceConfiguration.tintColor, for: .normal)
      advanceButton.titleLabel?.font = appearanceConfiguration.textFont
    }
    actionButton.sizeToFit()
    if let actionButtonStyling = appearanceConfiguration.actionButtonStyling {
      actionButtonStyling(actionButton)
    } else {
      actionButton.setTitleColor(appearanceConfiguration.tintColor, for: .normal)
      actionButton.titleLabel?.font = appearanceConfiguration.titleFont
    }
  }

  override func loadView() {
    view = UIView(frame: CGRect.zero)
    view.addSubview(titleLabel)
    view.addSubview(pageStackView)
    NSLayoutConstraint.activate([
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
      pageStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.0),
      pageStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
      pageStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      pageStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor)
      ])
    pageStackView.addArrangedSubview(imageView)
    pageStackView.addArrangedSubview(descriptionLabel)
    pageStackView.addArrangedSubview(actionButton)
    pageStackView.addArrangedSubview(advanceButton)

    actionButton.addTarget(self,
                           action: #selector(OnboardPageViewController.actionTapped),
                           for: .touchUpInside)
    advanceButton.addTarget(self,
                            action: #selector(OnboardPageViewController.advanceTapped),
                            for: .touchUpInside)

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    customizeButtonsWith(appearanceConfiguration)
  }

  func configureWithPage(_ page: OnboardPage) {
    configureTitleLabel(page.title)
    configureImageView(page.imageName)
    configureDescriptionLabel(page.description)
    configureActionButton(page.actionButtonTitle, action: page.action)
    configureAdvanceButton(page.advanceButtonTitle)
  }

  private func configureTitleLabel(_ title: String) {
    titleLabel.text = title
    NSLayoutConstraint.activate([
      titleLabel.widthAnchor.constraint(equalTo: pageStackView.widthAnchor, multiplier: 0.8)
      ])
  }

  private func configureImageView(_ imageName: String?) {
    if let imageName = imageName, let image = UIImage(named: imageName) {
      imageView.image = image
      imageView.heightAnchor.constraint(equalTo: pageStackView.heightAnchor, multiplier: 0.5).isActive = true
    } else {
      imageView.isHidden = true
    }
  }

  private func configureDescriptionLabel(_ description: String?) {
    if let pageDescription = description {
      descriptionLabel.text = pageDescription
      NSLayoutConstraint.activate([
        descriptionLabel.heightAnchor.constraint(greaterThanOrEqualTo: pageStackView.heightAnchor, multiplier: 0.2),
        descriptionLabel.widthAnchor.constraint(equalTo: pageStackView.widthAnchor, multiplier: 0.8)
        ])
    } else {
      descriptionLabel.isHidden = true
    }
  }

  private func configureActionButton(_ title: String?, action: OnboardPageAction?) {
    if let actionButtonTitle = title {
      actionButton.setTitle(actionButtonTitle, for: .normal)
    } else {
      actionButton.isHidden = true
    }
  }

  private func configureAdvanceButton(_ title: String) {
    advanceButton.setTitle(title, for: .normal)
  }

  // MARK: - User Actions
  @objc fileprivate func actionTapped() {
    delegate?.pageViewController(self, actionTappedAt: pageIndex)
  }

  @objc fileprivate func advanceTapped() {
    delegate?.pageViewController(self, advanceTappedAt: pageIndex)
  }
}


import UIKit

/**
 */
final public class OnboardViewController: UIViewController {

  private let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                            navigationOrientation: .horizontal,
                                                            options: nil)
  private let pageItems: [OnboardPage]
  private let appearanceConfiguration: AppearanceConfiguration
  private let completion: (() -> Void)?

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Initializes a new `OnboardViewController` to be presented
  /// The onboard view controller encapsulates the whole onboarding flow
  ///
  /// - Parameters:
  ///   - pageItems: An array of `OnboardPage` items
  ///   - appearanceConfiguration: An optional configuration struct for appearance customization
  ///   - completion: An optional completion block that gets executed when the onboarding VC is dismissed
  public init(pageItems: [OnboardPage],
              appearanceConfiguration: AppearanceConfiguration = AppearanceConfiguration(),
              completion: (() -> Void)? = nil) {
    self.pageItems = pageItems
    self.appearanceConfiguration = appearanceConfiguration
    self.completion = completion
    super.init(nibName: nil, bundle: nil)
  }

  override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  override public func loadView() {
    view = UIView(frame: CGRect.zero)
    view.backgroundColor = appearanceConfiguration.backgroundColor
    pageViewController.setViewControllers([pageViwControllerFor(pageIndex: 0)!],
                                          direction: .forward,
                                          animated: false,
                                          completion: nil)
    pageViewController.dataSource = self
    pageViewController.delegate = self
    pageViewController.view.frame = view.bounds

    let pageControlApperance = UIPageControl.appearance(whenContainedInInstancesOf: [OnboardViewController.self])
    pageControlApperance.pageIndicatorTintColor = appearanceConfiguration.tintColor.withAlphaComponent(0.3)
    pageControlApperance.currentPageIndicatorTintColor = appearanceConfiguration.tintColor

    addChild(pageViewController)
    view.addSubview(pageViewController.view)
    pageViewController.didMove(toParent: self)
  }

  private func pageViwControllerFor(pageIndex: Int) -> OnboardPageViewController? {
    let pageVC = OnboardPageViewController(pageIndex: pageIndex, appearanceConfiguration: appearanceConfiguration)
    guard pageIndex >= 0 else { return nil }
    guard pageIndex < pageItems.count else { return nil }
    pageVC.delegate = self
    pageVC.configureWithPage(pageItems[pageIndex])
    return pageVC
  }

  private func advanceToPageWithIndex(_ pageIndex: Int) {
    DispatchQueue.main.async { [weak self] in
      guard let nextPage = self?.pageViwControllerFor(pageIndex: pageIndex) else { return }
      self?.pageViewController.setViewControllers([nextPage],
                                                  direction: .forward,
                                                  animated: true,
                                                  completion: nil)
    }
  }
}

// MARK: Presenting
public extension OnboardViewController {

  /// Presents the configured `OnboardViewController`
  ///
  /// - Parameters:
  ///   - viewController: the presenting view controller
  ///   - animated: Defines if the presentation should be animated
  func presentFrom(_ viewController: UIViewController, animated: Bool) {
    viewController.present(self, animated: animated)
  }
}

extension OnboardViewController: UIPageViewControllerDataSource {

  public func pageViewController(_ pageViewController: UIPageViewController,
                                 viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let pageVC = viewController as? OnboardPageViewController else { return nil }
    let pageIndex = pageVC.pageIndex
    guard pageIndex != 0 else { return nil }
    return pageViwControllerFor(pageIndex: pageIndex - 1)
  }

  public func pageViewController(_ pageViewController: UIPageViewController,
                                 viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let pageVC = viewController as? OnboardPageViewController else { return nil }
    let pageIndex = pageVC.pageIndex
    return pageViwControllerFor(pageIndex: pageIndex + 1)
  }

  public func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return pageItems.count
  }

  public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    if let currentPage = pageViewController.viewControllers?.first as? OnboardPageViewController {
      return currentPage.pageIndex
    }
    return 0
  }
}

extension OnboardViewController: UIPageViewControllerDelegate {

}

extension OnboardViewController: OnboardPageViewControllerDelegate {

  func pageViewController(_ pageVC: OnboardPageViewController, actionTappedAt index: Int) {
    if let pageAction = pageItems[index].action {
      pageAction({ (success, error) in
        guard error == nil else { return }
        if success {
          self.advanceToPageWithIndex(index + 1)
        }
      })
    }
  }

  func pageViewController(_ pageVC: OnboardPageViewController, advanceTappedAt index: Int) {
    if index == pageItems.count - 1 {
      dismiss(animated: true, completion: self.completion)
    } else {
      advanceToPageWithIndex(index + 1)
    }
  }
}

// MARK: - AppearanceConfiguration
public extension OnboardViewController {

  typealias ButtonStyling = ((UIButton) -> Void)

  struct AppearanceConfiguration {
    /// The color used for the page indicator and buttons
    ///
    /// - note: Defualts to the blue tint color used troughout iOS
    let tintColor: UIColor

    /// The color used for the title text
    ///
    /// - note: If not specified, defualts to whatever `textColor` is
    let titleColor: UIColor

    /// The color used for the description text (and title text `titleColor` if not set)
    ///
    /// - note: Defualts to `.darkText`
    let textColor: UIColor

    /// The color used for onboarding background
    ///
    /// - note: Defualts to white
    let backgroundColor: UIColor

    /// The `contentMode` used for the slide imageView
    ///
    /// - note: Defualts to white
    let imageContentMode: UIView.ContentMode

    /// The font used for the title and action button
    ///
    /// - note: Defualts to preferred text style `.title1` (supports dinamyc type)
    let titleFont: UIFont

    /// The font used for the desctiption label and advance button
    ///
    /// - note: Defualts to preferred text style `.body` (supports dinamyc type)
    let textFont: UIFont

    /// A Swift closure used to expose and customize the button used to advance to the next page
    ///
    /// - note: Defualts to nil. If not used, the button will be customized based on the tint and text properties
    let advanceButtonStyling: ButtonStyling?

    /// A Swift closure used to expose and customize the button used to trigger page specific action
    ///
    /// - note: Defualts to nil. If not used, the button will be customized based on the title properties
    let actionButtonStyling: ButtonStyling?

    public init(tintColor: UIColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0),
                titleColor: UIColor? = nil,
                textColor: UIColor = .darkText,
                backgroundColor: UIColor = .white,
                imageContentMode: UIView.ContentMode = .center,
                titleFont: UIFont = UIFont.preferredFont(forTextStyle: .title1),
                textFont: UIFont = UIFont.preferredFont(forTextStyle: .body),
                advanceButtonStyling: ButtonStyling? = nil,
                actionButtonStyling: ButtonStyling? = nil) {
      self.tintColor = tintColor
      self.titleColor = titleColor ?? textColor
      self.textColor = textColor
      self.backgroundColor = backgroundColor
      self.imageContentMode = imageContentMode
      self.titleFont = titleFont
      self.textFont = textFont
      self.advanceButtonStyling = advanceButtonStyling
      self.actionButtonStyling = actionButtonStyling
    }
  }
}

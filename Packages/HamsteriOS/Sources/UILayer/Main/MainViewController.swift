//
//  File.swift
//
//
//  Created by morse on 2023/7/5.
//

import Combine
import HamsterUIKit
import UIKit

protocol SubViewControllerFactory {
  func makeSettingsViewController() -> SettingsViewController
  func makeInputSchemaViewController() -> InputSchemaViewController
  func makeFinderViewController() -> FinderViewController
  func makeKeyboardSettingsViewController() -> KeyboardSettingsViewController
  func makeKeyboardColorViewController() -> KeyboardColorViewController
  func makeKeyboardFeedbackViewController() -> KeyboardFeedbackViewController
  func makeUploadInputSchemaViewController() -> UploadInputSchemaViewController
  func makeAppleCloudViewController() -> AppleCloudViewController
  func makeBackupViewController() -> BackupViewController
  func makeAboutViewController() -> AboutViewController
  func makeOpenSourceProjectViewController() -> OpenSourceViewController
  func makeRimeViewController() -> RimeViewController
}

open class MainViewController: UISplitViewController {
  private let mainViewModel: MainViewModel
  private let subViewControllerFactory: SubViewControllerFactory
  private let settingsViewController: SettingsViewController

  private lazy var inputSchemaViewController: InputSchemaViewController
    = subViewControllerFactory.makeInputSchemaViewController()

  private lazy var finderViewController: FinderViewController
    = subViewControllerFactory.makeFinderViewController()

  private lazy var keyboardSettingsViewController: KeyboardSettingsViewController
    = subViewControllerFactory.makeKeyboardSettingsViewController()

  private lazy var keyboardColorViewController: KeyboardColorViewController
    = subViewControllerFactory.makeKeyboardColorViewController()

  private lazy var keyboardFeedbackViewController: KeyboardFeedbackViewController
    = subViewControllerFactory.makeKeyboardFeedbackViewController()

  private lazy var uploadInputSchemaViewController: UploadInputSchemaViewController
    = subViewControllerFactory.makeUploadInputSchemaViewController()

  private lazy var rimeViewController: RimeViewController
    = subViewControllerFactory.makeRimeViewController()

  private lazy var backupViewController: BackupViewController
    = subViewControllerFactory.makeBackupViewController()

  private lazy var iCloudViewController: AppleCloudViewController
    = subViewControllerFactory.makeAppleCloudViewController()

  private lazy var aboutViewController: AboutViewController
    = subViewControllerFactory.makeAboutViewController()

  private lazy var openSourceProjectViewController: OpenSourceViewController
    = subViewControllerFactory.makeOpenSourceProjectViewController()

  private lazy var emptyViewController: UIViewController = {
    let vc = NibLessViewController()
    return vc
  }()

  private lazy var primaryNavigationViewController: UINavigationController = {
    let vc = UINavigationController(rootViewController: settingsViewController)
    return vc
  }()

  private lazy var secondaryNavigationViewController: UINavigationController = {
    let vc = UINavigationController(rootViewController: aboutViewController)
    return vc
  }()

  private var subscriptions = Set<AnyCancellable>()

  init(mainViewModel: MainViewModel, subViewControllerFactory: SubViewControllerFactory) {
    self.mainViewModel = mainViewModel
    self.subViewControllerFactory = subViewControllerFactory
    self.settingsViewController = subViewControllerFactory.makeSettingsViewController()

    super.init(style: .doubleColumn)
    self.delegate = self
    // primary 视图始终可见
    self.presentsWithGesture = false
    self.preferredDisplayMode = .twoBesideSecondary
    self.preferredSplitBehavior = .tile
    self.displayModeButtonVisibility = .never
    self.showsSecondaryOnlyButton = false
    self.setViewController(primaryNavigationViewController, for: .primary)
    self.setViewController(secondaryNavigationViewController, for: .secondary)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - override UIViewController

extension MainViewController {
  override open func viewDidLoad() {
    super.viewDidLoad()

    /// 动态控制导航
    mainViewModel.$subView
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        self.navigationResponse(to: $0)
      }
      .store(in: &subscriptions)
  }
}

// MARK: - implementation UISplitViewControllerDelegate

extension MainViewController: UISplitViewControllerDelegate {
  public func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
    /// 首选显示 primary 列
    return .primary
  }
}

// MARK: - custom method

extension MainViewController {
  func navigationResponse(to subView: SettingsSubView) {
    switch subView {
    case .inputSchema:
      presentInputSchemaViewController()
    case .finder:
      presentFinderViewController()
    case .uploadInputSchema:
      presentUploadInputSchemaViewController()
    case .keyboardSettings:
      presentKeyboardSettingsViewController()
    case .colorSchema:
      presentKeyboardColorViewController()
    case .feedback:
      presentKeyboardFeedbackViewController()
    case .rime:
      presentRimeViewController()
    case .backup:
      presentBackupViewController()
    case .iCloud:
      presentAppleCloudViewController()
    case .about:
      presentAboutViewController()
    case .openSource:
      presentOpenSourceViewController()
    case .none:
      return
//      popToRootViewController(animated: false)
    default:
      return
    }
  }

  func presentInputSchemaViewController() {
    secondaryNavigationViewController.viewControllers = []
    setViewController(inputSchemaViewController, for: .secondary)
    show(.secondary)
  }

  func presentFinderViewController() {
    secondaryNavigationViewController.viewControllers = []
    setViewController(finderViewController, for: .secondary)
    show(.secondary)
  }

  func presentUploadInputSchemaViewController() {
    secondaryNavigationViewController.viewControllers = []
    setViewController(uploadInputSchemaViewController, for: .secondary)
    show(.secondary)
  }

  func presentKeyboardSettingsViewController() {
    secondaryNavigationViewController.viewControllers = []
    setViewController(keyboardSettingsViewController, for: .secondary)
    show(.secondary)
  }

  func presentKeyboardColorViewController() {
    secondaryNavigationViewController.viewControllers = []
    setViewController(keyboardColorViewController, for: .secondary)
    show(.secondary)
  }

  func presentKeyboardFeedbackViewController() {
    secondaryNavigationViewController.viewControllers = []
    setViewController(keyboardFeedbackViewController, for: .secondary)
    show(.secondary)
  }

  func presentRimeViewController() {
    secondaryNavigationViewController.viewControllers = []
    setViewController(rimeViewController, for: .secondary)
    show(.secondary)
  }

  func presentBackupViewController() {
    secondaryNavigationViewController.viewControllers = []
    setViewController(backupViewController, for: .secondary)
    show(.secondary)
  }

  func presentAppleCloudViewController() {
    secondaryNavigationViewController.viewControllers = []
    setViewController(iCloudViewController, for: .secondary)
    show(.secondary)
  }

  func presentAboutViewController() {
    secondaryNavigationViewController.viewControllers = []
    setViewController(aboutViewController, for: .secondary)
    show(.secondary)
  }

  func presentOpenSourceViewController() {
    secondaryNavigationViewController.viewControllers = []
    setViewController(openSourceProjectViewController, for: .secondary)
    show(.secondary)
  }
}

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

open class MainViewController: NibLessNavigationController {
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

  private var subscriptions = Set<AnyCancellable>()

  init(mainViewModel: MainViewModel, subViewControllerFactory: SubViewControllerFactory) {
    self.mainViewModel = mainViewModel
    self.subViewControllerFactory = subViewControllerFactory
    self.settingsViewController = subViewControllerFactory.makeSettingsViewController()

    super.init(rootViewController: settingsViewController)

    self.delegate = self
  }
}

// MARK: override UIViewController

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

// MARK: custom method

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
      popToRootViewController(animated: false)
    default:
      return
    }
  }

  func presentInputSchemaViewController() {
    pushViewController(inputSchemaViewController, animated: true)
  }

  func presentFinderViewController() {
    pushViewController(finderViewController, animated: true)
  }

  func presentUploadInputSchemaViewController() {
    pushViewController(uploadInputSchemaViewController, animated: true)
  }

  func presentKeyboardSettingsViewController() {
    pushViewController(keyboardSettingsViewController, animated: true)
  }

  func presentKeyboardColorViewController() {
    pushViewController(keyboardColorViewController, animated: true)
  }

  func presentKeyboardFeedbackViewController() {
    pushViewController(keyboardFeedbackViewController, animated: true)
  }

  func presentRimeViewController() {
    pushViewController(rimeViewController, animated: true)
  }

  func presentBackupViewController() {
    pushViewController(backupViewController, animated: true)
  }

  func presentAppleCloudViewController() {
    pushViewController(iCloudViewController, animated: true)
  }

  func presentAboutViewController() {
    pushViewController(aboutViewController, animated: true)
  }

  func presentOpenSourceViewController() {
    pushViewController(openSourceProjectViewController, animated: true)
  }
}

// MARK: implementation UINavigationControllerDelegate

extension MainViewController: UINavigationControllerDelegate {}

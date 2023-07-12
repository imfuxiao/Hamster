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
  func makeUploadInputSchemaViewController() -> UploadInputSchemaViewController
  func makeAppleCloudViewController() -> AppleCloudViewController
  func makeBackupViewController() -> BackupViewController
  func makeAboutViewController() -> AboutViewController
  func makeOpenSourceProjectViewController() -> OpenSourceViewController
  func makeRimeViewController() -> RimeViewController
}

open class MainViewController: NibLessNavigationController {
  private let mainViewModel: MainViewModel

  private let settingsViewController: SettingsViewController
  private let inputSchemaViewController: InputSchemaViewController
  private let finderViewController: FinderViewController
  private let uploadInputSchemaViewController: UploadInputSchemaViewController
  private let rimeViewController: RimeViewController
  private let backupViewController: BackupViewController
  private let iCloudViewController: AppleCloudViewController
  private let aboutViewController: AboutViewController
  private let openSourceProjectViewController: OpenSourceViewController

  private var subscriptions = Set<AnyCancellable>()

  init(mainViewModel: MainViewModel, subViewControllerFactory: SubViewControllerFactory) {
    self.mainViewModel = mainViewModel
    self.settingsViewController = subViewControllerFactory.makeSettingsViewController()
    self.inputSchemaViewController = subViewControllerFactory.makeInputSchemaViewController()
    self.finderViewController = subViewControllerFactory.makeFinderViewController()
    self.uploadInputSchemaViewController = subViewControllerFactory.makeUploadInputSchemaViewController()
    self.rimeViewController = subViewControllerFactory.makeRimeViewController()
    self.backupViewController = subViewControllerFactory.makeBackupViewController()
    self.iCloudViewController = subViewControllerFactory.makeAppleCloudViewController()
    self.aboutViewController = subViewControllerFactory.makeAboutViewController()
    self.openSourceProjectViewController = subViewControllerFactory.makeOpenSourceProjectViewController()

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

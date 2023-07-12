//
//  HamsterAppDependencyContainer.swift
//
//
//  Created by morse on 2023/7/5.
//

import Foundation
import HamsterKit
import HamsterModel
import os
import UIKit

/// Hamster 应用依赖容器
/// 通过此容器，为对象注入依赖
open class HamsterAppDependencyContainer {
  /// 单例
  public static let shared = HamsterAppDependencyContainer()

  private let logger = Logger(subsystem: "com.ihsiao.apps.hamster.HamsteriOS", category: "HamsterAppDependencyContainer")

  // MARK: Long-lived 依赖属性

  public let rimeContext: RimeContext
  public let mainViewModel: MainViewModel
  public let settingsViewModel: SettingsViewModel
  public let inputSchemaViewModel: InputSchemaViewModel
  
  /// 应用配置
  /// 注意：应用首次启动时需要先将配置从配置文件中加载到 UserDefault 中
  public var configuration: HamsterConfiguration {
    didSet {
      Task {
        do {
          try await HamsterConfigurationRepositories.shared.saveToUserDefaults(configuration)
          logger.debug("configuration save success")
        } catch {
          logger.error("configuration didSet error: \(error.localizedDescription)")
        }
      }
    }
  }

  private init() {
    func makeMainViewModel() -> MainViewModel {
      MainViewModel()
    }

    func makeSettingsViewModel(
      mainViewModel: MainViewModel,
      rimeContext: RimeContext,
      configuration: HamsterConfiguration
    ) -> SettingsViewModel {
      SettingsViewModel(
        mainViewModel: mainViewModel,
        rimeContext: rimeContext,
        configuration: configuration
      )
    }

    func makeInputSchemaViewModel(rimeContext: RimeContext) -> InputSchemaViewModel {
      InputSchemaViewModel(rimeContext: rimeContext)
    }

    if UserDefaults.hamster.isFirstRunning {
      self.configuration = HamsterConfiguration()
    } else {
      do {
        self.configuration = try HamsterConfigurationRepositories.shared.loadFromUserDefaults()
      } catch {
        logger.error("loadFromUserDefaults error: \(error.localizedDescription)")
        self.configuration = HamsterConfiguration()
      }
    }

    self.rimeContext = RimeContext()
    self.mainViewModel = makeMainViewModel()
    self.settingsViewModel = makeSettingsViewModel(
      mainViewModel: mainViewModel,
      rimeContext: rimeContext,
      configuration: configuration
    )
    self.inputSchemaViewModel = makeInputSchemaViewModel(rimeContext: rimeContext)
  }
}

extension HamsterAppDependencyContainer {
  func makeZipDocumentPickerViewController() -> UIDocumentPickerViewController {
    UIDocumentPickerViewController(forOpeningContentTypes: [.zip])
  }
}

extension HamsterAppDependencyContainer: UploadInputSchemaViewModelFactory {
  func makeUploadInputSchemaViewModel() -> UploadInputSchemaViewModel {
    return UploadInputSchemaViewModel()
  }
}

extension HamsterAppDependencyContainer: RimeViewModelFactory {
  func makeRimeViewModel() -> RimeViewModel {
    return RimeViewModel(rimeContext: rimeContext)
  }
}

extension HamsterAppDependencyContainer: BackupViewModelFactory {
  func makeBackupViewModel() -> BackupViewModel {
    return BackupViewModel(fileBrowserViewModel: makeFileBrowserViewModel(rootURL: FileManager.sandboxBackupDirectory))
  }
}

extension HamsterAppDependencyContainer: FinderViewModelFactory {
  func makeFinderViewModel() -> FinderViewModel {
    return FinderViewModel(configuration: configuration)
  }
}

extension HamsterAppDependencyContainer: FileBrowserViewModelFactory {
  func makeFileBrowserViewModel(rootURL: URL) -> FileBrowserViewModel {
    let fileBrowserViewModel = FileBrowserViewModel(rootURL: rootURL)
    return fileBrowserViewModel
  }
}

extension HamsterAppDependencyContainer: AppleCloudViewModelFactory {
  func makeAppleCloudViewModel() -> AppleCloudViewModel {
    return AppleCloudViewModel(settingsViewModel: settingsViewModel)
  }
}

extension HamsterAppDependencyContainer: AboutViewModelFactory {
  func makeAboutViewModel() -> AboutViewModel {
    return AboutViewModel(mainViewModel: mainViewModel)
  }
}

extension HamsterAppDependencyContainer: OpenSourceViewModelFactory {
  func makeOpenSourceViewModel() -> OpenSourceViewModel {
    return OpenSourceViewModel()
  }
}

extension HamsterAppDependencyContainer: SubViewControllerFactory {
  public func makeRootController() -> MainViewController {
    let navigationController = MainViewController(mainViewModel: mainViewModel, subViewControllerFactory: self)
    return navigationController
  }

  public func makeSettingsViewController() -> SettingsViewController {
    let settingViewController = SettingsViewController(settingsViewModel: settingsViewModel)
    return settingViewController
  }

  func makeInputSchemaViewController() -> InputSchemaViewController {
    let inputSchemaViewController = InputSchemaViewController(
      inputSchemaViewModel: inputSchemaViewModel,
      documentPickerViewController: makeZipDocumentPickerViewController()
    )
    return inputSchemaViewController
  }

  func makeFinderViewController() -> FinderViewController {
    let finderViewController = FinderViewController(finderViewModelFactory: self, fileBrowserViewModelFactory: self)
    return finderViewController
  }

  func makeUploadInputSchemaViewController() -> UploadInputSchemaViewController {
    let uploadInputSchemaViewController = UploadInputSchemaViewController(
      uploadInputSchemaViewModelFactory: self
    )
    return uploadInputSchemaViewController
  }

  func makeAppleCloudViewController() -> AppleCloudViewController {
    let iCloudViewController = AppleCloudViewController(appleCloudViewModelFactory: self)
    return iCloudViewController
  }

  func makeRimeViewController() -> RimeViewController {
    let rimeViewController = RimeViewController(rimeViewModelFactory: self)
    return rimeViewController
  }

  func makeBackupViewController() -> BackupViewController {
    let backupViewController = BackupViewController(backupViewModelFactory: self)
    return backupViewController
  }

  func makeAboutViewController() -> AboutViewController {
    let aboutViewController = AboutViewController(aboutViewModelFactory: self)
    return aboutViewController
  }

  func makeOpenSourceProjectViewController() -> OpenSourceViewController {
    return OpenSourceViewController(openSourceViewModelFactory: self)
  }
}

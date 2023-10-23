//
//  HamsterAppDependencyContainer.swift
//
//
//  Created by morse on 2023/7/5.
//

import Foundation
import HamsterKeyboardKit
import HamsterKit
import OSLog
import UIKit

/// Hamster 应用依赖注入容器
/// 通过此容器，为对象注入依赖
open class HamsterAppDependencyContainer {
  /// 单例
  public static let shared = HamsterAppDependencyContainer()

  // MARK: Long-lived 依赖属性

  public let rimeContext: RimeContext
  public let mainViewModel: MainViewModel

  public lazy var settingsViewModel: SettingsViewModel = {
    let vm = SettingsViewModel(
      mainViewModel: mainViewModel,
      rimeContext: rimeContext
    )
    return vm
  }()

  public lazy var rimeViewModel: RimeViewModel = {
    let vm = RimeViewModel(rimeContext: rimeContext)
    return vm
  }()

  public lazy var backupViewModel: BackupViewModel = {
    let vm = BackupViewModel(fileBrowserViewModel: makeFileBrowserViewModel(rootURL: FileManager.sandboxBackupDirectory))
    return vm
  }()

  public lazy var inputSchemaViewModel: InputSchemaViewModel = {
    let vm = InputSchemaViewModel(rimeContext: rimeContext)
    return vm
  }()

  public lazy var keyboardSettingsViewModel: KeyboardSettingsViewModel = {
    let vm = KeyboardSettingsViewModel()
    return vm
  }()

  /// 应用配置
  /// 注意：应用首次启动时需要先将配置从配置文件中加载到 UserDefault 中
  public var configuration: HamsterConfiguration {
    didSet {
      Task {
        do {
          Logger.statistics.debug("hamster configuration didSet")
          try HamsterConfigurationRepositories.shared.saveToUserDefaults(configuration)
          try HamsterConfigurationRepositories.shared.saveToYAML(config: configuration, yamlPath: FileManager.hamsterConfigFileOnUserDataSupport)
        } catch {
          Logger.statistics.error("hamster configuration didSet error: \(error.localizedDescription)")
        }
      }
    }
  }

  // 应用默认配置
  // 注意：
  // 1. 此配置用于还原系统默认配置
  // 2. 计算属性
  public var defaultConfiguration: HamsterConfiguration? {
    do {
      return try HamsterConfigurationRepositories.shared.loadFromUserDefaultsOnDefault()
    } catch {
      Logger.statistics.error("loadFromUserDefaultsOnDefault() error: \(error)")
      return nil
    }
  }

  private init() {
    // 创建 long-lived 属性
    self.rimeContext = RimeContext()
    self.mainViewModel = MainViewModel()

    // 判断应用是否首次运行
    // 注意 UserDefaults.hamster.isFirstRunning 标志位在 SettingsViewModel 的 loadAppData() 方法内重置
    if UserDefaults.hamster.isFirstRunning {
      do {
        // 首次运行解压 zip 文件（包含应用内置输入方案及配置文件）
        try FileManager.initSandboxSharedSupportDirectory(override: true)

        // 读取 Hamster.yaml, 生成应用全局配置
        let hamsterConfiguration = try HamsterConfigurationRepositories.shared.loadFromYAML(FileManager.hamsterConfigFileOnSandboxSharedSupport)

        // 保存应用配置
        try HamsterConfigurationRepositories.shared.saveToUserDefaults(hamsterConfiguration)

        // 作为应用的默认配置，可从默认值中恢复
        try HamsterConfigurationRepositories.shared.saveToUserDefaultsOnDefault(hamsterConfiguration)

        self.configuration = hamsterConfiguration
      } catch {
        self.configuration = HamsterConfiguration()
        Logger.statistics.error("init SharedSupport error: \(error.localizedDescription)")
      }
      return
    }

    // 非首次启动从 UserDefault 文件中加载
    do {
      self.configuration = try HamsterConfigurationRepositories.shared.loadFromUserDefaults()
    } catch {
      Logger.statistics.error("load configuration from UserDefault error: \(error.localizedDescription)")
      // 如果从 UserDefaults 加载失败，则尝试从配置文件中加载一次
      if let hamsterConfiguration = try? HamsterConfigurationRepositories.shared.loadFromYAML(FileManager.hamsterConfigFileOnSandboxSharedSupport) {
        self.configuration = hamsterConfiguration
      } else {
        self.configuration = HamsterConfiguration()
      }
    }
  }

  /// 重置应用配置
  public func resetHamsterConfiguration() {
    HamsterConfigurationRepositories.shared.resetConfiguration()
  }
}

extension HamsterAppDependencyContainer {
  func makeZipDocumentPickerViewController() -> UIDocumentPickerViewController {
    let vc = UIDocumentPickerViewController(forOpeningContentTypes: [.zip])
    if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
      vc.directoryURL = iCloudURL
    } else {
      vc.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    return vc
  }
}

extension HamsterAppDependencyContainer: UploadInputSchemaViewModelFactory {
  func makeUploadInputSchemaViewModel() -> UploadInputSchemaViewModel {
    return UploadInputSchemaViewModel()
  }
}

extension HamsterAppDependencyContainer: FinderViewModelFactory {
  func makeFinderViewModel() -> FinderViewModel {
    return FinderViewModel()
  }
}

extension HamsterAppDependencyContainer: KeyboardSettingsSubViewControllerFactory {
  func makeNumberNineGridSettingsViewController() -> NumberNineGridSettingsViewController {
    NumberNineGridSettingsViewController(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }

  func makeSymbolSettingsViewController() -> SymbolSettingsViewController {
    SymbolSettingsViewController(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }

  func makeSymbolKeyboardSettingsViewController() -> SymbolKeyboardSettingsViewController {
    SymbolKeyboardSettingsViewController(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }

  func makeToolbarSettingsViewController() -> ToolbarSettingsViewController {
    ToolbarSettingsViewController(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }

  func makeKeyboardLayoutViewController() -> KeyboardLayoutViewController {
    KeyboardLayoutViewController(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }

  func makeSpaceSettingsViewController() -> SpaceSettingsViewController {
    SpaceSettingsViewController(keyboardSettingsViewModel: keyboardSettingsViewModel)
  }
}

extension HamsterAppDependencyContainer: KeyboardColorViewModelFactory {
  func makeKeyboardColorViewModel() -> KeyboardColorViewModel {
    KeyboardColorViewModel()
  }
}

extension HamsterAppDependencyContainer: KeyboardFeedbackViewModelFactory {
  func makeKeyboardFeedbackViewModel() -> KeyboardFeedbackViewModel {
    KeyboardFeedbackViewModel()
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
    return AboutViewModel()
  }
}

extension HamsterAppDependencyContainer: OpenSourceViewControllerFactory {
  func makeOpenSourceViewController() -> OpenSourceViewController {
    return OpenSourceViewController(openSourceViewModelFactory: self)
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
    let settingViewController = SettingsViewController(settingsViewModel: settingsViewModel, rimeViewModel: rimeViewModel, backupViewModel: backupViewModel)
    return settingViewController
  }

  func makeInputSchemaViewController() -> InputSchemaViewController {
    let inputSchemaViewController = InputSchemaViewController(
      inputSchemaViewModel: inputSchemaViewModel,
      documentPickerViewController: makeZipDocumentPickerViewController()
    )
    return inputSchemaViewController
  }

  func makeUploadInputSchemaViewController() -> UploadInputSchemaViewController {
    let uploadInputSchemaViewController = UploadInputSchemaViewController(
      uploadInputSchemaViewModelFactory: self
    )
    return uploadInputSchemaViewController
  }

  func makeFinderViewController() -> FinderViewController {
    let finderViewController = FinderViewController(finderViewModelFactory: self, fileBrowserViewModelFactory: self)
    return finderViewController
  }

  func makeKeyboardSettingsViewController() -> KeyboardSettingsViewController {
    let keyboardSettingsViewController = KeyboardSettingsViewController(
      keyboardSettingsViewModel: keyboardSettingsViewModel,
      keyboardSettingsSubViewControllerFactory: self
    )
    return keyboardSettingsViewController
  }

  func makeKeyboardColorViewController() -> KeyboardColorViewController {
    KeyboardColorViewController(keyboardColorViewModelFactory: self)
  }

  func makeKeyboardFeedbackViewController() -> KeyboardFeedbackViewController {
    KeyboardFeedbackViewController(keyboardFeedbackViewModelFactory: self)
  }

  func makeAppleCloudViewController() -> AppleCloudViewController {
    let iCloudViewController = AppleCloudViewController(appleCloudViewModelFactory: self)
    return iCloudViewController
  }

  func makeRimeViewController() -> RimeViewController {
    let rimeViewController = RimeViewController(rimeViewModel: rimeViewModel)
    return rimeViewController
  }

  func makeBackupViewController() -> BackupViewController {
    let backupViewController = BackupViewController(backupViewModel: backupViewModel)
    return backupViewController
  }

  func makeAboutViewController() -> AboutViewController {
    let aboutViewController = AboutViewController(
      aboutViewModelFactory: self,
      openSourceViewControllerFactory: self
    )
    return aboutViewController
  }
}

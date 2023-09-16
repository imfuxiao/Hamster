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

/// Hamster 应用依赖容器
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
      rimeContext: rimeContext,
      configuration: configuration
    )
    return vm
  }()

  public lazy var inputSchemaViewModel: InputSchemaViewModel = {
    let vm = InputSchemaViewModel(rimeContext: rimeContext)
    return vm
  }()

  public lazy var keyboardSettingsViewModel: KeyboardSettingsViewModel = {
    let vm = KeyboardSettingsViewModel(configuration: configuration)
    return vm
  }()

  // 应用默认配置
  // 注意：此配置用于还原系统默认配置
  public var defaultConfiguration: HamsterConfiguration? {
    do {
      return try HamsterConfigurationRepositories.shared.loadFromUserDefaultsOnDefault()
    } catch {
      Logger.statistics.error("loadFromUserDefaultsOnDefault() error: \(error)")
      return nil
    }
  }

  /// 应用配置
  /// 注意：应用首次启动时需要先将配置从配置文件中加载到 UserDefault 中
  private var configCache: HamsterConfiguration?
  public var configuration: HamsterConfiguration {
    get {
      if let config = configCache {
        return config
      }
      if let config = try? HamsterConfigurationRepositories.shared.loadFromUserDefaults() {
        configCache = config
        return config
      }
      Logger.statistics.warning("load HamsterConfiguration from UserDefaults error.")
      return HamsterConfiguration()
    }
    set {
      configCache = newValue
      Task {
        do {
          try await HamsterConfigurationRepositories.shared.saveToUserDefaults(newValue)
        } catch {
          Logger.statistics.error("configuration didSet error: \(error.localizedDescription)")
        }
      }
    }
  }

  private init() {
    // 创建 long-lived 属性
    self.rimeContext = RimeContext()
    self.mainViewModel = MainViewModel()
  }

  /// 重置应用配置
  public func resetHamsterConfiguration() {
    configCache = nil
    HamsterConfigurationRepositories.shared.resetConfiguration()
  }
}

extension HamsterAppDependencyContainer {
  func makeZipDocumentPickerViewController() -> UIDocumentPickerViewController {
    let vc = UIDocumentPickerViewController(forOpeningContentTypes: [.zip])
    vc.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return vc
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
}

extension HamsterAppDependencyContainer: KeyboardColorViewModelFactory {
  func makeKeyboardColorViewModel() -> KeyboardColorViewModel {
    KeyboardColorViewModel(settingsViewModel: settingsViewModel, configuration: configuration)
  }
}

extension HamsterAppDependencyContainer: KeyboardFeedbackViewModelFactory {
  func makeKeyboardFeedbackViewModel() -> KeyboardFeedbackViewModel {
    KeyboardFeedbackViewModel(configuration: configuration)
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
    let rimeViewController = RimeViewController(rimeViewModelFactory: self)
    return rimeViewController
  }

  func makeBackupViewController() -> BackupViewController {
    let backupViewController = BackupViewController(backupViewModelFactory: self)
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

//
//  RimeViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import Combine
import Foundation
import HamsterKeyboardKit
import HamsterKit
import OSLog
import ProgressHUD
import UIKit

public class RimeViewModel {
  private let rimeContext: RimeContext

  // 简繁切换键值
  public var keyValueOfSwitchSimplifiedAndTraditional: String {
    get {
      HamsterAppDependencyContainer.shared.configuration.rime?.keyValueOfSwitchSimplifiedAndTraditional ?? ""
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.rime?.keyValueOfSwitchSimplifiedAndTraditional = newValue
    }
  }

  // 是否覆盖词库文件
  // 非造词用户保持默认值 true
  public var overrideDictFiles: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.rime?.overrideDictFiles ?? true
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.rime?.overrideDictFiles = newValue
    }
  }

  lazy var settings: [SettingItemModel] = [
    .init(
      icon: UIImage(systemName: "square.and.pencil"),
      placeholder: "简繁切换键值",
      type: .textField,
      textValue: { [unowned self] in keyValueOfSwitchSimplifiedAndTraditional },
      textHandled: { [unowned self] in
        keyValueOfSwitchSimplifiedAndTraditional = $0
      }
    ),
    .init(
      text: "部署时覆盖键盘词库文件",
      type: .toggle,
      toggleValue: { [unowned self] in overrideDictFiles },
      toggleHandled: { [unowned self] in
        overrideDictFiles = $0
      }
    ),
    .init(
      text: "重新部署",
      type: .button,
      buttonAction: { [unowned self] in
        Task {
          await rimeDeploy()
          reloadTableSubject.send(true)
        }
      },
      favoriteButton: .rimeDeploy
    ),
    .init(
      text: "RIME同步",
      type: .button,
      buttonAction: { [unowned self] in
        Task {
          await rimeSync()
        }
      },
      favoriteButton: .rimeSync
    ),
    .init(
      text: "RIME重置",
      textTintColor: .systemRed,
      type: .button,
      buttonAction: { [unowned self] in
        Task {
          await rimeRest()
          reloadTableSubject.send(true)
        }
      },
      favoriteButton: .rimeRest
    )
  ]

  private var reloadTableSubject = PassthroughSubject<Bool, Never>()
  public var reloadTablePublished: AnyPublisher<Bool, Never> {
    reloadTableSubject.eraseToAnyPublisher()
  }

  init(rimeContext: RimeContext) {
    self.rimeContext = rimeContext
  }
}

public extension RimeViewModel {
  /// RIME 部署
  func rimeDeploy() async {
    await ProgressHUD.show("RIME部署中, 请稍候……", interaction: false)

    var hamsterConfiguration = HamsterAppDependencyContainer.shared.configuration

    do {
      try await rimeContext.deployment(configuration: hamsterConfiguration)

      // 读取 Rime 目录下 hamster.yaml 配置文件，如果存在
      if let configuration =
        try? HamsterConfigurationRepositories.shared.loadFromYAML(FileManager.hamsterConfigFileOnUserDataSupport)
      {
        hamsterConfiguration = configuration
      }

      // 读取 Rime 目录下 hamster.custom.yaml 配置文件(如果存在)，并对相异的配置做 merge 合并（已 hamster.custom.yaml 文件为主）
      if let patchConfiguration =
        try? HamsterConfigurationRepositories.shared.loadPatchFromYAML(yamlPath: FileManager.hamsterPatchConfigFileOnUserDataSupport),
        let configuration = patchConfiguration.patch
      {
        hamsterConfiguration = try hamsterConfiguration.merge(
          with: configuration,
          uniquingKeysWith: { _, patchValue in patchValue }
        )
      }

      HamsterAppDependencyContainer.shared.configuration = hamsterConfiguration

      await ProgressHUD.showSuccess("部署成功", interaction: false, delay: 1.5)
    } catch {
      Logger.statistics.error("rime deploy error: \(error)")
      await ProgressHUD.showError("部署失败", interaction: false, delay: 1.5)
    }
  }

  /// RIME 同步
  func rimeSync() async {
    do {
      await ProgressHUD.show("RIME同步中, 请稍候……", interaction: false)
      // 先打开iCloud地址，防止Crash
      _ = URL.iCloudDocumentURL

      // 增加同步路径检测（sync_dir），检测是否有权限写入。
      if let syncDir = FileManager.sandboxInstallationYaml.getSyncPath() {
        if !FileManager.default.fileExists(atPath: syncDir) {
          do {
            try FileManager.default.createDirectory(atPath: syncDir, withIntermediateDirectories: true)
          } catch {
            throw "同步地址无写入权限：\(syncDir)"
          }
        } else {
          if !FileManager.default.isWritableFile(atPath: syncDir) {
            throw "同步地址无写入权限：\(syncDir)"
          }
        }
      }
      try await rimeContext.syncRime()
      await ProgressHUD.showSuccess("同步成功", interaction: false, delay: 1.5)
    } catch {
      Logger.statistics.error("rime sync error: \(error)")
      await ProgressHUD.showError("同步失败", interaction: false, delay: 1.5)
    }
  }

  /// Rime重置
  func rimeRest() async {
    await ProgressHUD.show("RIME重置中, 请稍候……", interaction: false)
    do {
      try await rimeContext.restRime()

      // 重置应用配置
      HamsterAppDependencyContainer.shared.resetHamsterConfiguration()

      // 重新读取 Hamster.yaml 生成 configuration
      let hamsterConfiguration = try HamsterConfigurationRepositories.shared.loadFromYAML(FileManager.hamsterConfigFileOnSandboxSharedSupport)
      HamsterAppDependencyContainer.shared.configuration = hamsterConfiguration

      /// 在另存一份用于应用配置还原
      try HamsterConfigurationRepositories.shared.saveToUserDefaultsOnDefault(hamsterConfiguration)

      await ProgressHUD.showSuccess("重置成功", interaction: false, delay: 1.5)
    } catch {
      Logger.statistics.error("rimeRest() error: \(error)")
      await ProgressHUD.showError("重置失败", interaction: false, delay: 1.5)
    }
  }
}

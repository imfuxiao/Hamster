//
//  RimeViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import Foundation
import HamsterKit
import ProgressHUD

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

  init(rimeContext: RimeContext) {
    self.rimeContext = rimeContext
  }
}

extension RimeViewModel {
  /// RIME 部署
  func rimeDeploy() async throws {
    await ProgressHUD.show("RIME部署中, 请稍候……", interaction: false)
    // TODO: 每次重新部署重新读取yaml中的文件，并与目前配置取差集
    try await rimeContext.deployment(configuration: HamsterAppDependencyContainer.shared.configuration)
    await ProgressHUD.showSuccess("部署成功", interaction: false, delay: 1.5)
  }

  /// RIME 同步
  func rimeSync() async throws {
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
  }

  /// Rime重置
  func rimeRest() async throws {
    await ProgressHUD.show("RIME重置中, 请稍候……", interaction: false)
    // TODO: 每次重新部署重新读取yaml中的文件，并与目前配置取差集

    try await rimeContext.restRime()
    await ProgressHUD.showSuccess("重置成功", interaction: false, delay: 1.5)
  }
}

//
//  RimeSyncIntent.swift
//  Hamster
//
//  Created by morse on 22/6/2023.
//

import AppIntents
import HamsteriOS
import HamsterKit
import OSLog

@available(iOS 16.0, *)
struct RimeSyncIntent: AppIntent {
  static var title: LocalizedStringResource = "RIME 同步"

  static var description = IntentDescription("仓输入法 - RIME 同步")

  static var openAppWhenRun: Bool {
    return false
  }

  static var authenticationPolicy: IntentAuthenticationPolicy {
    .alwaysAllowed
  }

  func perform() async throws -> some ReturnsValue & ProvidesDialog {
    do {
      let hamsterConfiguration = HamsterAppDependencyContainer.shared.configuration
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

      try HamsterAppDependencyContainer.shared.rimeContext.syncRime(configuration: hamsterConfiguration)
      return .result(dialog: .init("RIME 同步完成"))
    } catch {
      Logger.statistics.error("RimeSyncIntent failed: \(error)")
      return .result(dialog: .init("RIME 同步失败"))
    }
  }
}

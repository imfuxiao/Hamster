//
//  RimeSyncIntent.swift
//  Hamster
//
//  Created by morse on 22/6/2023.
//

import AppIntents

@available(iOS 16.0, *)
struct RimeSyncIntent: AppIntent {
  static var title: LocalizedStringResource = "RIME同步"

  static var description =
    IntentDescription("仓输入法 RIME 同步")

  @MainActor
  func perform() async throws -> some IntentResult {
    // 先打开iCloud地址，防止Crash
    _ = FileManager.iCloudDocumentURL

    // 增加同步路径检测（sync_dir），检测是否有权限写入。
    if let syncDir = FileManager.default.getSyncPath(RimeContext.sandboxInstallationYaml) {
      if !FileManager.default.fileExists(atPath: syncDir) {
        do {
          try FileManager.default.createDirectory(atPath: syncDir, withIntermediateDirectories: true)
        } catch {
          return .result(dialog: .init("同步地址权限异常"))
        }
      } else {
        if !FileManager.default.isWritableFile(atPath: syncDir) {
          return .result(dialog: .init("同步地址权限异常"))
        }
      }
    }

    do {
      // 将AppGroup下词库文件copy至应用目录
      // 默认只拷贝 userdb 格式（二进制格式）用户词库文件
      try RimeContext.shared.copyAppGroupUserDict()

      // 同步
      let handled = try RimeContext.shared.syncRime()
      if !handled {
        return .result(dialog: .init("RIME 同步异常"))
      }
      HamsterAppSettings.shared.rimeNeedOverrideUserDataDirectory = true
    } catch {
      return .result(dialog: .init("RIME 同步异常"))
    }
    return .result(dialog: .init("RIME 同步完成"))
  }
}

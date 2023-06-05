//
//  RIMEViewModel.swift
//  Hamster
//
//  Created by morse on 19/5/2023.
//

import Foundation
import ProgressHUD

struct RIMEViewModel {
  let rimeContext: RimeContext
  let appSettings: HamsterAppSettings

  /// 部署
  func deployment() -> Bool {
    ProgressHUD.show("部署中，请稍后……", interaction: false)

    do {
      try rimeContext.redeployment(appSettings)
    } catch {
      ProgressHUD.showError("部署失败", delay: 1.5)
      Logger.shared.log.error("rime redeployment error \(error.localizedDescription)")
      return false
    }

    // 重置rime相关参数
    DispatchQueue.main.async {
      let resetHandled = appSettings.resetRimeParameter()
      Logger.shared.log.debug("rimeEngine resetRimeParameter \(resetHandled)")

      if resetHandled {
        ProgressHUD.showSuccess("部署成功", delay: 1.5)
      } else {
        ProgressHUD.showError("部署失败", delay: 1.5)
      }
    }

    return true
  }

  /// Rime同步
  func rimeSync() {
    ProgressHUD.show("RIME同步中……", interaction: false)

    // 先打开iCloud地址，防止Crash
    _ = FileManager.iCloudDocumentURL

    // 增加同步路径检测（sync_dir），检测是否有权限写入。
    if let syncDir = FileManager.default.getSyncPath(RimeContext.sandboxInstallationYaml) {
      if !FileManager.default.fileExists(atPath: syncDir) {
        do {
          try FileManager.default.createDirectory(atPath: syncDir, withIntermediateDirectories: true)
        } catch {
          ProgressHUD.showError("同步地址：\(syncDir)，无写入权限", delay: 1.5)
          return
        }
      } else {
        if !FileManager.default.isWritableFile(atPath: syncDir) {
          ProgressHUD.showError("同步地址：\(syncDir)，无写入权限", delay: 1.5)
          return
        }
      }
    }

    do {
      // 将AppGroup下词库文件copy至应用目录
      // 默认只拷贝 userdb 格式（二进制格式）用户词库文件
      try rimeContext.copyAppGroupUserDict()
      
      // 同步
      let handled = try rimeContext.syncRime()
      if !handled {
        ProgressHUD.showError("同步失败", delay: 1.5)
        return
      }
    } catch {
      ProgressHUD.showError("同步失败", delay: 1.5)
      Logger.shared.log.error("rime sync error \(error.localizedDescription)")
      return
    }

    ProgressHUD.showSuccess("同步成功", delay: 1.5)
  }

  /// Rime重置
  func rimeRest() -> Bool {
    ProgressHUD.show("RIME重置中, 请稍候……", interaction: true)

    // 重置输入方案目录
    do {
      try RimeContext.initSandboxSharedSupportDirectory(override: true)
      try RimeContext.initSandboxUserDataDirectory(override: true)
    } catch {
      ProgressHUD.dismiss()
      return false
    }

    ProgressHUD.show("部署中……", interaction: true)

    // 部署
    let deployHandled = Rime.shared.deploy(Rime.createTraits(
      sharedSupportDir: RimeContext.sandboxSharedSupportDirectory.path,
      userDataDir: RimeContext.sandboxUserDataDirectory.path
    ))
    Logger.shared.log.debug("rimeEngine deploy handled \(deployHandled)")

    // 重置rime相关参数
    DispatchQueue.main.async {
      appSettings.enableAppleCloud = false
      let resetHandled = appSettings.resetRimeParameter()
      Logger.shared.log.debug("rimeEngine resetRimeParameter \(resetHandled)")
    }

    // 将 Sandbox 目录下方案复制到AppGroup下
    try? RimeContext.syncSandboxSharedSupportDirectoryToApGroup(override: true)
    try? RimeContext.syncSandboxUserDataDirectoryToApGroup(override: true)

    ProgressHUD.showSuccess("重置成功", delay: 1.5)
    return true
  }
}

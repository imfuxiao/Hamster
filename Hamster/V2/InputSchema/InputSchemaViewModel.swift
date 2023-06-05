//
//  InputSchemaViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//
import ProgressHUD
import UIKit

class InputSchemaViewModel {
  init(appSettings: HamsterAppSettings, rimeContext: RimeContext) {
    self.appSettings = appSettings
    self.rimeContext = rimeContext
  }

  private let appSettings: HamsterAppSettings
  private let rimeContext: RimeContext
}

extension InputSchemaViewModel {
  // 导入zip文件
  func importZipFile(fileURL: URL, tableView: UITableView) {
    Logger.shared.log.debug("file.fileName: \(fileURL.path)")

    ProgressHUD.show("方案导入中……", interaction: false)

    var needStopAccessingSecurityScopedResource = false

    // Start accessing a security-scoped resource.
    // 检测是否为iCloudURL, 需要特殊处理
    if fileURL.path.contains("com~apple~CloudDocs") {
      // iCloud中的URL须添加安全访问资源语句，否则会异常：Operation not permitted
      // startAccessingSecurityScopedResource与stopAccessingSecurityScopedResource必须成对出现
      guard fileURL.startAccessingSecurityScopedResource() else {
        // Handle the failure here.
        Logger.shared.log.debug("startAccessingSecurityScopedResource() failed: \(fileURL.path)")
        ProgressHUD.showError("导入失败", interaction: false, delay: 1.5)
        return
      }

      needStopAccessingSecurityScopedResource = true
    }

    // Make sure you release the security-scoped resource when you finish.
    defer {
      if needStopAccessingSecurityScopedResource {
        fileURL.stopAccessingSecurityScopedResource()
      }
    }

    do {
      let fm = FileManager.default
      let (handled, zipErr) = try fm.unzip(Data(contentsOf: fileURL), dst: RimeContext.sandboxUserDataDirectory)
      if !handled {
        ProgressHUD.showError("导入Zip方案失败。\(zipErr?.localizedDescription ?? "")", interaction: false, delay: 3)
        return
      }

      ProgressHUD.show("方案部署中……", interaction: false)

      let traits = Rime.createTraits(
        sharedSupportDir: RimeContext.sandboxSharedSupportDirectory.path,
        userDataDir: RimeContext.sandboxUserDataDirectory.path
      )
      let deployHandled = Rime.shared.deploy(traits)
      Logger.shared.log.debug("rimeEngine deploy handled \(deployHandled)")

      DispatchQueue.main.async { [unowned self] in
        let resetHandled = self.appSettings.resetRimeParameter()
        // 复制输入方案至AppGroup下
        try? RimeContext.syncSandboxUserDataDirectoryToApGroup(override: true)
        ProgressHUD.showSuccess("导入成功", interaction: false, delay: 1.5)
        Logger.shared.log.debug("rimeEngine resetRimeParameter \(resetHandled)")
        tableView.reloadData()
      }

    } catch {
      Logger.shared.log.debug("zip \(error)")
      ProgressHUD.showError("导入Zip方案失败。\(error.localizedDescription)", interaction: false, delay: 3)
    }
  }
}

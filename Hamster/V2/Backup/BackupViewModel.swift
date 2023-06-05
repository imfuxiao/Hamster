//
//  BackupViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import Foundation
import ProgressHUD

class BackupViewModel {
  init(controller: BackupViewController) {
    self.controller = controller
    self.appSettings = controller.appSettings
  }

  private var appSettings: HamsterAppSettings
  private unowned var controller: BackupViewController

  func backup() {
    ProgressHUD.show("软件备份中，请等待……", interaction: false)
    DispatchQueue.global().async { [unowned self] in
      do {
        try FileManager.default.hamsterBackup(appSettings: appSettings)
        DispatchQueue.main.async { [unowned self] in
          controller.loadBackupFiles()
          controller.tableView.reloadData()
        }
      } catch {
        Logger.shared.log.error("App backup error: \(error.localizedDescription)")
        ProgressHUD.showError("备份异常", interaction: false, delay: 1.5)
        return
      }
      ProgressHUD.showSuccess("备份成功", interaction: false, delay: 1.5)
    }
  }

  func restore(fileInfo: FileInfo) {
    ProgressHUD.show("恢复中，请等待……", interaction: false)
    let selectRestoreFileURL = fileInfo.url
    DispatchQueue.global().async { [unowned self] in
      do {
        try FileManager.default.hamsterRestore(selectRestoreFileURL, appSettings: appSettings)
      } catch {
        Logger.shared.log.error("App restore error: \(error.localizedDescription)")
        ProgressHUD.showError("恢复异常", interaction: false, delay: 1.5)
        return
      }
      ProgressHUD.showSuccess("恢复成功", delay: 1.5)
    }
  }

  func rename(at fileURL: URL, newFileName: String) {
    guard !newFileName.isEmpty else { return }

    let newFileURL = fileURL.deletingLastPathComponent()
      .appendingPathComponent(newFileName.hasSuffix(".zip") ? newFileName : newFileName + ".zip", isDirectory: false)

    try? FileManager.default.moveItem(at: fileURL, to: newFileURL)
    controller.loadBackupFiles()
    controller.tableView.reloadData()
  }
}

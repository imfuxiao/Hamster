//
//  FileManagerViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import ProgressHUD
import UIKit

class FileManagerViewModel {
  init(appSettings: HamsterAppSettings, rimeContext: RimeContext) {
    self.appSettings = appSettings
    self.rimeContext = rimeContext
  }

  unowned var controller: FileManagerViewController?
  private let appSettings: HamsterAppSettings
  private let rimeContext: RimeContext
}

extension FileManagerViewModel {
  func copyAppGroupDictFileToAppDocument() {
    DispatchQueue.global().async { [unowned self] in
      ProgressHUD.show("拷贝中……", interaction: true)
      do {
        try self.rimeContext.copyAppGroupUserDict(["^.*[.]userdb.*$", "^.*[.]txt$"])
      } catch {
        ProgressHUD.showError("拷贝失败：\(error.localizedDescription)")
        return
      }
      ProgressHUD.showSuccess("拷贝词库成功", delay: 1.5)
    }
  }

  func overrideAppDocument() {
    DispatchQueue.global().async {
      ProgressHUD.show("覆盖中……", interaction: true)
      do {
        // 使用AppGroup下文件覆盖应用Sandbox下文件
        try RimeContext.syncAppGroupSharedSupportDirectoryToSandbox(override: true)
        try RimeContext.syncAppGroupUserDataDirectoryToSandbox(override: true)
      } catch {
        ProgressHUD.showError("覆盖失败：\(error.localizedDescription)")
        return
      }
      ProgressHUD.showSuccess("完成", delay: 1.5)
    }
  }

  @objc func segmentChangeAction(sender: UISegmentedControl) {
    guard let controller = controller else { return }
    switch sender.selectedSegmentIndex {
    case 0:
      controller.switchSettingView()
    case 1:
      controller.switchAppFileBrowse()
    case 2:
      controller.switchAppGroupFileBrowse()
    case 3:
      controller.switchAppleCloudBrowse()
    default:
      return
    }
  }
}

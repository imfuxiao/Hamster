//
//  File+iCloud.swift
//  Hamster
//
//  Created by morse on 2/5/2023.
//

import Combine
import Foundation

extension FileManager {
  // 应用iCloud文件夹
  // 注意：appendingPathComponent("Documents")是非常重要的一点，如果没有它，你的文件夹将不会显示在iCloud Drive里面。
  static var iCloudDocumentURL: URL? {
    if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
      return icloudURL.appendingPathComponent("Documents")
    }
    return nil
  }

  // iCloud中RIME使用文件路径
  static var iCloudRimeURL: URL {
    iCloudDocumentURL!.appendingPathComponent("RIME")
  }

  // iCloud中 RIME sharedSupport 路径
  static var iCloudSharedSupportURL: URL {
    iCloudRimeURL.appendingPathComponent(AppConstants.rimeSharedSupportPathName)
  }

  // iCloud中 RIME 方案 userData 路径
  static var iCloudUserDataURL: URL {
    iCloudRimeURL.appendingPathComponent(AppConstants.rimeUserPathName)
  }

  // iCloud 中 RIME 方案同步路径
  static var iCloudRimeSyncURL: URL {
    iCloudRimeURL.appendingPathComponent("sync")
  }

  // iCloud 中 软件备份路径
  static var iCloudBackupsURL: URL {
    iCloudDocumentURL!.appendingPathComponent("backups")
  }
}

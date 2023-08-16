//
//  File.swift
//
//
//  Created by morse on 2023/7/4.
//

import Foundation
import os
import Yams

public extension URL {
  /// 获取制定URL下文件或目录URL
  func getFilesAndDirectories() -> [URL] {
    do {
      return try FileManager.default.contentsOfDirectory(
        at: self,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
      )
    } catch {
      Logger.statistics.error("Error getting files and directories - \(error.localizedDescription)")
      return []
    }
  }

  /// 获取指定URL路径下 .schema.yaml 文件URL
//  func getSchemesFile() -> [URL] {
//    getFilesAndDirectories()
//      .filter { $0.lastPathComponent.hasSuffix(".schema.yaml") }
//  }

  /// 获取指定URL的文件内容
  func getStringFromFile() -> String? {
    guard let data = FileManager.default.contents(atPath: path) else {
      return nil
    }
    return String(data: data, encoding: .utf8)
  }

  /// 获取 RIME 同步路径位置
  func getSyncPath() -> String? {
    guard let yamlContent = getStringFromFile() else { return nil }
    do {
      if let yamlFileContent = try Yams.load(yaml: yamlContent) as? [String: Any] {
        return yamlFileContent["sync_dir"] as? String
      }
    } catch {
      Logger.statistics.error("yaml load error \(error.localizedDescription), url:\(self.path)")
    }
    return nil
  }
}

// MARK: iCloud 相关地址

public extension URL {
  // 应用iCloud文件夹
  // 注意：appendingPathComponent("Documents")是非常重要的一点，如果没有它，你的文件夹将不会显示在iCloud Drive里面。
  static var iCloudDocumentURL: URL? = {
    if let icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
      return icloudURL.appendingPathComponent("Documents")
    }
    return nil
  }()

  // TODO: 这里需要重写
  // iCloud中RIME使用文件路径
  static var iCloudRimeURL: URL {
    iCloudDocumentURL!.appendingPathComponent("RIME")
  }

  // iCloud中 RIME sharedSupport 路径
  static var iCloudSharedSupportURL: URL {
    iCloudRimeURL.appendingPathComponent(HamsterConstants.rimeSharedSupportPathName)
  }

  // iCloud中 RIME 方案 userData 路径
  static var iCloudUserDataURL: URL {
    iCloudRimeURL.appendingPathComponent(HamsterConstants.rimeUserPathName)
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

//
//  File+Backup.swift
//  Hamster
//
//  Created by morse on 7/5/2023.
//

import Foundation
import Plist
import Yams
import ZIPFoundation

extension FileManager {
  enum BackupError: Error {
    case generatorAppSettingsYamlError
  }
  
  static var tempBackupDirectory: URL {
    FileManager.default.temporaryDirectory
      .appendingPathComponent("HamsterBackup")
  }
  
  static var tempSharedSupportDirectory: URL {
    tempBackupDirectory.appendingPathComponent("RIME").appendingPathComponent(AppConstants.rimeSharedSupportPathName)
  }
  
  static var tempUserDataDirectory: URL {
    tempBackupDirectory.appendingPathComponent("RIME").appendingPathComponent(AppConstants.rimeUserPathName)
  }
  
  static var tempAppSettingsYaml: URL {
    tempBackupDirectory.appendingPathComponent("appSettings.yaml")
  }
  
  static var tempSwipePlist: URL {
    tempBackupDirectory.appendingPathComponent("swipe.plist")
  }
  
  static var backupFileNameDateFormat: DateFormatter {
    let format = DateFormatter()
    format.locale = Locale(identifier: "zh_Hans_SG")
    format.dateFormat = "yyyyMMdd-HHmmss"
    return format
  }
  
  // 创建备份文件
  func hamsterBackup(appSettings: HamsterAppSettings) throws {
    // 创建备份临时文件夹
    try FileManager.createDirectory(override: true, dst: FileManager.tempBackupDirectory)
    
    // copy 当前输入方案
    try FileManager.copyDirectory(override: true, src: RimeContext.sandboxSharedSupportDirectory, dst: FileManager.tempSharedSupportDirectory)
    try FileManager.copyDirectory(override: true, src: RimeContext.sandboxUserDataDirectory, dst: FileManager.tempUserDataDirectory)
    
    // 生成App配置文件
    let settingYaml = appSettings.yaml()
    if settingYaml.isEmpty {
      throw BackupError.generatorAppSettingsYamlError
    } else {
      try settingYaml.write(toFile: FileManager.tempAppSettingsYaml.path, atomically: true, encoding: .utf8)
    }
    
    // 生成上下滑动配置文件
    let fileData = try Plist(appSettings.keyboardSwipeGestureSymbol).toData()
    try fileData.write(to: FileManager.tempSwipePlist)
    
    // 生成zip包至备份目录。
//    let backupURL = appSettings.enableAppleCloud ? FileManager.iCloudBackupsURL : RimeEngine.sandboxBackupDirectory
    let backupURL = RimeContext.sandboxBackupDirectory
    try FileManager.createDirectory(dst: backupURL)
    
    let fileName = FileManager.backupFileNameDateFormat.string(from: Date())
    
    // 生成zip包
    try zipItem(at: FileManager.tempBackupDirectory, to: backupURL.appendingPathComponent("\(fileName).zip"))
  }
  
  /// 备份文件列表
  func backupFiles(appSettings: HamsterAppSettings) -> [URL] {
    let backupDirectoryURL = RimeContext.sandboxBackupDirectory
    do {
      return try contentsOfDirectory(at: backupDirectoryURL, includingPropertiesForKeys: nil)
        .filter {
          $0.lastPathComponent.hasSuffix(".zip")
        }
    } catch {
      return []
    }
  }
  
  /// 恢复
  func hamsterRestore(_ backupURL: URL, appSettings: HamsterAppSettings) throws {
    // 解压zip
    if fileExists(atPath: FileManager.tempBackupDirectory.path) {
      try removeItem(at: FileManager.tempBackupDirectory)
    }
    try unzipItem(at: backupURL, to: FileManager.default.temporaryDirectory)
    
    // 恢复输入方案
    try FileManager.copyDirectory(override: true, src: FileManager.tempSharedSupportDirectory, dst: RimeContext.sandboxSharedSupportDirectory)
    try FileManager.copyDirectory(override: true, src: FileManager.tempUserDataDirectory, dst: RimeContext.sandboxUserDataDirectory)
    
    // 恢复AppSettings
    if let yaml = getStringFromFile(at: FileManager.tempAppSettingsYaml), let node = try Yams.compose(yaml: yaml) {
      DispatchQueue.main.async {
        appSettings.reset(node: node)
      }
    }
    
    // 恢复滑动手势设置
    if let data = contents(atPath: FileManager.tempSwipePlist.path) {
      DispatchQueue.main.async {
        let plist = Plist(data: data)
        appSettings.keyboardSwipeGestureSymbol = plist.strDict
      }
    }
  }
  
  func deleteBackupFile(_ backupURL: URL) throws {
    try FileManager.default.removeItem(at: backupURL)
  }
}

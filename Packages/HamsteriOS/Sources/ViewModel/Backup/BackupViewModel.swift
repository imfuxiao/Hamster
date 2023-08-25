//
//  BackupViewModel.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import Foundation
import HamsterKit
import OSLog
import ProgressHUD
import ZIPFoundation

class BackupViewModel {
  // MARK: properties

  lazy var settingItem = SettingItemModel(
    text: "软件备份",
    buttonAction: { [unowned self] in
      Task {
        try await backup()
      }
    },
    favoriteButton: .appBackup
  )
  /// 备份文件列表
  @Published
  var backupFiles: [FileInfo] = []

  @Published
  var backupSwipeAction: BackupSwipeAction?

  /// 选择文件
  var selectFile: FileInfo?

  private let fileBrowserViewModel: FileBrowserViewModel

  // MARK: methods

  init(fileBrowserViewModel: FileBrowserViewModel) {
    self.fileBrowserViewModel = fileBrowserViewModel
  }

  func loadBackupFiles() async {
    backupFiles = await fileBrowserViewModel.currentPathFiles().filter { $0.url.pathExtension.lowercased() == "zip" }
  }

  /// 备份应用
  func backup() async throws {
    await ProgressHUD.show("软件备份中，请等待……", interaction: false)
    do {
      try await makeBackup()
      await loadBackupFiles()
    } catch {
      Logger.statistics.error("App backup error: \(error.localizedDescription)")
      throw error
    }
    await ProgressHUD.showSuccess("备份成功", interaction: false, delay: 1.5)
  }

  /// 应用恢复
  func restore(fileInfo: FileInfo) async throws {
    await ProgressHUD.show("恢复中，请等待……", interaction: false)
    let selectRestoreFileURL = fileInfo.url
    do {
      // 解压zip
      if FileManager.default.fileExists(atPath: FileManager.tempBackupDirectory.path) {
        try FileManager.default.removeItem(at: FileManager.tempBackupDirectory)
      }

      try FileManager.default.unzipItem(at: selectRestoreFileURL, to: FileManager.default.temporaryDirectory)

      // 恢复输入方案
      try FileManager.copyDirectory(override: true, src: FileManager.tempSharedSupportDirectory, dst: FileManager.sandboxSharedSupportDirectory)
      try FileManager.copyDirectory(override: true, src: FileManager.tempUserDataDirectory, dst: FileManager.sandboxUserDataDirectory)

      // 恢复设置
      let configuration = try await HamsterConfigurationRepositories.shared.loadFromYAML(yamlPath: FileManager.tempAppConfigurationYaml)
      HamsterAppDependencyContainer.shared.configuration = configuration
    } catch {
      Logger.statistics.error("App restore error: \(error.localizedDescription)")
      throw error
    }
    await ProgressHUD.showSuccess("恢复成功", delay: 1.5)
  }

  /// 修改备份文件名称
  func renameBackupFile(at fileURL: URL, newFileName: String) async throws {
    guard !newFileName.isEmpty else { return }

    let newFileURL = fileURL.deletingLastPathComponent()
      .appendingPathComponent(newFileName.hasSuffix(".zip") ? newFileName : newFileName + ".zip", isDirectory: false)

    try? FileManager.default.moveItem(at: fileURL, to: newFileURL)
  }

  /// 创建备份文件
  private func makeBackup() async throws {
    // 创建备份临时文件夹
    try FileManager.createDirectory(override: true, dst: FileManager.tempBackupDirectory)

    // copy 当前输入方案
    try FileManager.copyDirectory(override: true, src: FileManager.sandboxSharedSupportDirectory, dst: FileManager.tempSharedSupportDirectory)
    try FileManager.copyDirectory(override: true, src: FileManager.sandboxUserDataDirectory, dst: FileManager.tempUserDataDirectory)

    // 生成当前配置文件
    let configuration = try HamsterConfigurationRepositories.shared.loadFromUserDefaults()
    try await HamsterConfigurationRepositories.shared.saveToYAML(config: configuration, yamlPath: FileManager.tempAppConfigurationYaml)

    // 生成zip包至备份目录。
    let backupURL = FileManager.sandboxBackupDirectory
    try FileManager.createDirectory(dst: backupURL)

    let fileName = DateFormatter.tempFileNameStyle.string(from: Date())

    // 生成zip包
    try FileManager.default.zipItem(at: FileManager.tempBackupDirectory, to: backupURL.appendingPathComponent("\(fileName).zip"))
  }

  /// 删除备份文件
  func deleteBackupFile(_ backupURL: URL) throws {
    try FileManager.default.removeItem(at: backupURL)
  }
}

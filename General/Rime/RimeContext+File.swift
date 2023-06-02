//
//  RimeEngine+File.swift
//  Hamster
//
//  Created by morse on 7/3/2023.
//
import Foundation
import SwiftUI
import ZIPFoundation

extension RimeContext {
  // AppGroup共享目录
  // 注意：AppGroup已变为Keyboard复制方案使用的中转站
  // App内部使用位置在 Document 和 iCloud 下
  public static var shareURL: URL {
    FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: AppConstants.appGroupName)!
      .appendingPathComponent("InputSchema")
  }

  static var sandboxDirectory: URL {
    try! FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
  }

  // AppGroup共享下: SharedSupport目录
  static var appGroupSharedSupportDirectoryURL: URL {
    shareURL.appendingPathComponent(
      AppConstants.rimeSharedSupportPathName, isDirectory: true)
  }

  // AppGroup共享下: userData目录
  static var appGroupUserDataDirectoryURL: URL {
    shareURL.appendingPathComponent(
      AppConstants.rimeUserPathName, isDirectory: true)
  }

  // 沙盒 Document 目录下备份目录
  static var appGroupBackupDirectory: URL {
    shareURL.appendingPathComponent("backups", isDirectory: true)
  }

  // AppGroup共享下：userData目录下: default.custom.yaml文件路径
  static var appGroupUserDataDefaultCustomYaml: URL {
    appGroupUserDataDirectoryURL.appendingPathComponent("default.custom.yaml")
  }
  
  // Sandbox下：userData目录下: default.custom.yaml文件路径
  static var sandboxUserDataDefaultCustomYaml: URL {
    sandboxUserDataDirectory.appendingPathComponent("default.custom.yaml")
  }

  // AppGroup共享下：userData目录下: installation.yaml文件路径
  static var appGroupInstallationYaml: URL {
    appGroupUserDataDirectoryURL.appendingPathComponent("installation.yaml")
  }

  // Sandbox下：userData目录下: installation.yaml文件路径
  static var sandboxInstallationYaml: URL {
    sandboxUserDataDirectory.appendingPathComponent("installation.yaml")
  }

  // 沙盒 Document 目录下 ShareSupport 目录
  static var sandboxSharedSupportDirectory: URL {
    sandboxDirectory
      .appendingPathComponent(AppConstants.rimeSharedSupportPathName, isDirectory: true)
  }

  // 沙盒 Document 目录下 userData 目录
  static var sandboxUserDataDirectory: URL {
    sandboxDirectory
      .appendingPathComponent(AppConstants.rimeUserPathName, isDirectory: true)
  }

  // 沙盒 Document 目录下备份目录
  static var sandboxBackupDirectory: URL {
    sandboxDirectory.appendingPathComponent("backups", isDirectory: true)
  }

  // 安装包ShareSupport资源目录
  public static var appSharedSupportDirectory: URL {
    Bundle.main.bundleURL
      .appendingPathComponent(AppConstants.rimeSharedSupportPathName, isDirectory: true)
  }

  // 初始化 AppGroup 共享目录下 UserData 目录资源
  static func initAppGroupUserDataDirectory(override: Bool = false) throws {
    try FileManager.createDirectory(override: override, dst: appGroupUserDataDirectoryURL)
  }

  // 初始化沙盒目录下 UserData 目录资源
  static func initSandboxUserDataDirectory(override: Bool = false) throws {
    try FileManager.createDirectory(override: override, dst: sandboxUserDataDirectory)
  }

  // 同步 AppGroup 共享目录下SharedSupport目录至沙盒目录
  static func syncAppGroupSharedSupportDirectoryToSandbox(override: Bool = false) throws {
    Logger.shared.log.info("rime syncAppGroupSharedSupportDirectory: override \(override)")
    try FileManager.copyDirectory(override: override, src: appGroupSharedSupportDirectoryURL, dst: sandboxSharedSupportDirectory)
  }

  // 同步 AppGroup 共享目录下 UserData 目录至沙盒目录
  static func syncAppGroupUserDataDirectoryToSandbox(override: Bool = false) throws {
    Logger.shared.log.info("rime syncAppGroupUserDataDirectory: override \(override)")
    try FileManager.copyDirectory(override: override, src: appGroupUserDataDirectoryURL, dst: sandboxUserDataDirectory)
  }

  // 同步 Sandbox 目录下 SharedSupport 目录至 AppGroup 目录
  static func syncSandboxSharedSupportDirectoryToApGroup(override: Bool = false) throws {
    Logger.shared.log.info("rime syncSandboxSharedSupportDirectoryToApGroup: override \(override)")
    try FileManager.copyDirectory(override: override, src: sandboxSharedSupportDirectory, dst: appGroupSharedSupportDirectoryURL)
  }

  // 同步 Sandbox 目录下 UserData 目录至 AppGroup 目录
  static func syncSandboxUserDataDirectoryToApGroup(override: Bool = false) throws {
    Logger.shared.log.info("rime syncSandboxUserDataDirectoryToApGroup: override \(override)")
    try FileManager.copyDirectory(override: override, src: sandboxUserDataDirectory, dst: appGroupUserDataDirectoryURL)
  }

  /// 拷贝 Sandbox 下 SharedSupport 目录至 AppGroup 下 SharedSupport 目录
  static func copySandboxSharedSupportDirectoryToAppGroup(_ filterRegex: [String] = [], filterMatchBreak: Bool = true) throws {
    Logger.shared.log.info("rime copySandboxSharedSupportDirectoryToAppGroupSharedSupportDirectory: fileRegex \(filterRegex)")
    try FileManager.incrementalCopy(src: sandboxSharedSupportDirectory, dst: appGroupSharedSupportDirectoryURL, filterRegex: filterRegex, filterMatchBreak: filterMatchBreak)
  }

  /// 拷贝 Sandbox 下 UserData 目录至 AppGroup 下 UserData 目录
  static func copySandboxUserDataDirectoryToAppGroup(_ filterRegex: [String] = [], filterMatchBreak: Bool = true) throws {
    Logger.shared.log.info("rime copySandboxUserDataDirectoryToAppGroupUserDirectory: filterRegex \(filterRegex)")
    try FileManager.incrementalCopy(src: sandboxUserDataDirectory, dst: appGroupUserDataDirectoryURL, filterRegex: filterRegex, filterMatchBreak: filterMatchBreak)
  }

  /// 拷贝 Sandbox 下 SharedSupport 目录至 AppGroup 下 SharedSupport 目录
  static func copySandboxSharedSupportDirectoryToAppleCloud(_ filterRegex: [String] = [], filterMatchBreak: Bool = true) throws {
    Logger.shared.log.info("rime copySandboxSharedSupportDirectoryToAppleCloud: fileRegex \(filterRegex)")
    try FileManager.incrementalCopy(src: sandboxSharedSupportDirectory, dst: FileManager.iCloudSharedSupportURL, filterRegex: filterRegex, filterMatchBreak: filterMatchBreak)
  }

  /// 拷贝 Sandbox 下 UserData 目录至 AppGroup 下 UserData 目录
  static func copySandboxUserDataDirectoryToAppleCloud(_ filterRegex: [String] = [], filterMatchBreak: Bool = true) throws {
    Logger.shared.log.info("rime copySandboxUserDataDirectoryToAppleCloud: filterRegex \(filterRegex)")
    try FileManager.incrementalCopy(src: sandboxUserDataDirectory, dst: FileManager.iCloudUserDataURL, filterRegex: filterRegex, filterMatchBreak: filterMatchBreak)
  }

  /// 拷贝 iCloud 下 SharedSupport 目录至 Sandbox 下 SharedSupport 目录
  static func copyAppleCloudSharedSupportDirectoryToSandbox(_ filterRegex: [String] = []) throws {
    Logger.shared.log.info("rime copyAppleCloudSharedSupportDirectoryToSandboxSharedSupportDirectory")
    try FileManager.incrementalCopy(src: FileManager.iCloudSharedSupportURL, dst: sandboxSharedSupportDirectory, filterRegex: filterRegex)
  }

  /// 拷贝 iCloud 下 UserData 目录至 Sandbox 下 UserData 目录
  static func copyAppleCloudUserDataDirectoryToSandbox(_ filterRegex: [String] = []) throws {
    Logger.shared.log.info("rime copyAppleCloudUserDataDirectoryToSandboxUserDirectory:")
    try FileManager.incrementalCopy(src: FileManager.iCloudUserDataURL, dst: sandboxUserDataDirectory, filterRegex: filterRegex)
  }

  /// 拷贝 iCloud 下 SharedSupport 目录至 AppGroup 下 SharedSupport 目录
  static func copyAppleCloudSharedSupportDirectoryToAppGroup(_ filterRegex: [String] = []) throws {
    Logger.shared.log.info("rime copyAppleCloudSharedSupportDirectoryToAppGroupSharedSupportDirectory")
    try FileManager.incrementalCopy(src: FileManager.iCloudSharedSupportURL, dst: appGroupSharedSupportDirectoryURL, filterRegex: filterRegex)
  }

  /// 拷贝 iCloud 下 UserData 目录至 AppGroup 下 UserData 目录
  static func copyAppleCloudUserDataDirectoryToAppGroup(_ filterRegex: [String] = []) throws {
    Logger.shared.log.info("rime copyAppleCloudUserDataDirectoryToAppGroupUserDirectory:")
    try FileManager.incrementalCopy(src: FileManager.iCloudUserDataURL, dst: appGroupUserDataDirectoryURL, filterRegex: filterRegex)
  }

  /// 拷贝 AppGroup 下 SharedSupport 目录至 iCloud 下 SharedSupport 目录
  static func copyAppGroupSharedSupportDirectoryToAppleCloud(_ filterRegex: [String] = [], filterMatchBreak: Bool = true) throws {
    Logger.shared.log.info("rime copyAppGroupSharedSupportDirectoryToAppleCloudSharedSupportDirectory")
    try FileManager.incrementalCopy(src: appGroupSharedSupportDirectoryURL, dst: FileManager.iCloudSharedSupportURL, filterRegex: filterRegex, filterMatchBreak: filterMatchBreak)
  }

  /// 拷贝 AppGroup 下 UserData 目录至 iCloud 下 UserData 目录
  static func copyAppGroupUserDirectoryToAppleCloud(_ filterRegex: [String] = [], filterMatchBreak: Bool = true) throws {
    Logger.shared.log.info("rime copyAppGroupUserDirectoryToAppleCloudUserDataDirectory:")
    try FileManager.incrementalCopy(src: appGroupUserDataDirectoryURL, dst: FileManager.iCloudUserDataURL, filterRegex: filterRegex, filterMatchBreak: filterMatchBreak)
  }

  /// 拷贝 AppGroup 下 SharedSupport 目录至 sandbox 下 SharedSupport 目录
  static func copyAppGroupSharedSupportDirectoryToSandbox(_ filterRegex: [String] = [], filterMatchBreak: Bool = true, override: Bool = true) throws {
    Logger.shared.log.info("rime copyAppGroupSharedSupportDirectoryToAppleCloudSharedSupportDirectory")
    try FileManager.incrementalCopy(src: appGroupSharedSupportDirectoryURL, dst: sandboxSharedSupportDirectory, filterRegex: filterRegex, filterMatchBreak: filterMatchBreak, override: override)
  }

  /// 拷贝 AppGroup 下 UserData 目录至 sandbox 下 UserData 目录
  static func copyAppGroupUserDirectoryToSandbox(_ filterRegex: [String] = [], filterMatchBreak: Bool = true, override: Bool = true) throws {
    Logger.shared.log.info("rime copyAppGroupUserDirectoryToAppleCloudUserDataDirectory:")
    try FileManager.incrementalCopy(src: appGroupUserDataDirectoryURL, dst: sandboxUserDataDirectory, filterRegex: filterRegex, filterMatchBreak: filterMatchBreak, override: override)
  }
}

//
//  RimeEngine+File.swift
//  Hamster
//
//  Created by morse on 7/3/2023.
//
import Foundation
import SwiftUI
import ZIPFoundation

// Zip文件解析异常
struct ZipParsingError: Error {
  let message: String
}

extension RimeEngine {
  // AppGroup共享目录
  public static var shareURL: URL {
    FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: AppConstants.appGroupName)!
      .appendingPathComponent("InputSchema")
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

  // 沙盒Document目录下ShareSupport目录
  static var sharedSupportDirectory: URL {
    try! FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      .appendingPathComponent(AppConstants.rimeSharedSupportPathName, isDirectory: true)
  }

  // 沙盒Document目录下userData目录
  static var userDataDirectory: URL {
    try! FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      .appendingPathComponent(AppConstants.rimeUserPathName, isDirectory: true)
  }

  // 安装包ShareSupport资源目录
  private static var appSharedSupportDirectory: URL {
    Bundle.main.bundleURL
      .appendingPathComponent(AppConstants.rimeSharedSupportPathName, isDirectory: true)
  }

  // 初始化AppGroup共享目录下SharedSupport目录资源
  static func initAppGroupSharedSupportDirectory(override: Bool = false) throws {
    let fm = FileManager()
    let dst = appGroupSharedSupportDirectoryURL
    if fm.fileExists(atPath: dst.path) {
      if override {
        try fm.removeItem(atPath: dst.path)
      } else {
        return
      }
    }

    if !fm.fileExists(atPath: dst.path) {
      try fm.createDirectory(at: dst, withIntermediateDirectories: true, attributes: nil)
    }

    let src = appSharedSupportDirectory.appendingPathComponent(AppConstants.inputSchemaZipFile)
    // 解压缩输入方案zip文件
    // 因为zip文件中已经包含了SharedSupport目录, 所以需要解压到appSharedSupportDirectory的上层目录
    try fm.unzipItem(at: src, to: shareURL)
  }

  // 初始化AppGroup共享目录下UserData目录资源
  static func initAppGroupUserDataDirectory(override: Bool = false) throws {
    let fm = FileManager.default
    let dst = appGroupUserDataDirectoryURL
    if fm.fileExists(atPath: dst.path) {
      if override {
        try fm.removeItem(atPath: dst.path)
      } else {
        return
      }
    }
    try fm.createDirectory(at: dst, withIntermediateDirectories: true, attributes: nil)
  }

  // 初始化应用沙盒目录下UserData目录
  static func initUserDataDirectory() throws {
    let fm = FileManager.default
    let dst = userDataDirectory
    if fm.fileExists(atPath: dst.path) {
      return
    }
    try fm.createDirectory(at: dst, withIntermediateDirectories: true)
  }

  // 同步AppGroup共享目录下SharedSupport目录至沙盒目录
  static func syncAppGroupSharedSupportDirectory(override: Bool = false) throws {
    Logger.shared.log.info("rime syncAppGroupSharedSupportDirectory: override \(override)")
    let fm = FileManager.default
    let dst = sharedSupportDirectory

    if fm.fileExists(atPath: dst.path) {
      if override {
        try fm.removeItem(atPath: dst.path)
      } else {
        return
      }
    }

    let src = appGroupSharedSupportDirectoryURL
    try fm.copyItem(at: src, to: dst)
  }

  // 同步AppGroup共享目录下UserData目录至沙盒目录
  static func syncAppGroupUserDataDirectory(override: Bool = false) throws {
    Logger.shared.log.info("rime syncAppGroupUserDataDirectory: override \(override)")
    let fm = FileManager.default
    let dst = userDataDirectory

    if fm.fileExists(atPath: dst.path) {
      if override {
        try fm.removeItem(atPath: dst.path)
      } else {
        return
      }
    }

    let src = appGroupUserDataDirectoryURL
    try fm.copyItem(at: src, to: dst)
    try fm.setAttributes([.posixPermissions: 0o777], ofItemAtPath: dst.path)
  }

  // 解压至用户数据目录
  // 返回值
  // Bool 处理是否成功
  // Error: 处理失败的Error
  static func unzipUserData(_ zipURL: URL) throws -> (Bool, Error?) {
    let fm = FileManager()
    var tempURL = zipURL

    // 检测是否为iCloudURL, 需要特殊处理
    if zipURL.path.contains("com~apple~CloudDocs") {
      // iCloud中的URL须添加安全访问资源语句，否则会异常：Operation not permitted
      // startAccessingSecurityScopedResource与stopAccessingSecurityScopedResource必须成对出现
      if !zipURL.startAccessingSecurityScopedResource() {
        throw ZipParsingError(message: "Zip文件读取权限受限")
      }

      let tempPath = fm.temporaryDirectory.appendingPathComponent(zipURL.lastPathComponent)

      // 临时文件如果存在需要先删除
      if fm.fileExists(atPath: tempPath.path) {
        try fm.removeItem(at: tempPath)
      }

      try fm.copyItem(atPath: zipURL.path, toPath: tempPath.path)

      // 停止读取url文件
      zipURL.stopAccessingSecurityScopedResource()

      tempURL = tempPath
    }

    // 读取ZIP内容
    guard let archive = Archive(url: tempURL, accessMode: .read) else {
      return (false, ZipParsingError(message: "读取Zip文件异常"))
    }

    // 查找解压的文件夹里有没有名字包含schema.yaml 的文件
    guard let _ = archive.filter({ $0.path.contains("schema.yaml") }).first else {
      return (false, ZipParsingError(message: "Zip文件未包含输入方案文件"))
    }

    // 解压前先删除原Rime目录
    try fm.removeItem(at: RimeEngine.appGroupUserDataDirectoryURL)
    try fm.unzipItem(at: tempURL, to: RimeEngine.appGroupUserDataDirectoryURL)
    return (true, nil)
  }
}

//
//  RimeEngine+File.swift
//  Hamster
//
//  Created by morse on 7/3/2023.
//

import Foundation

extension RimeEngine {
  // AppGroup共享目录
  static var shareURL: URL {
    FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: AppConstants.appGroupName)!
  }

  // AppGroup共享下: userData目录
  static var appGroupUserDataDirectoryURL: URL {
    let appGroupUserDataURL = shareURL.appendingPathComponent(
      AppConstants.rimeUserPathName, isDirectory: true)
    if !FileManager.default.fileExists(atPath: appGroupUserDataURL.path) {
      do {
        try FileManager.default.createDirectory(
          at: appGroupUserDataURL, withIntermediateDirectories: true)
      } catch {
        print("create directory error for AppGroup's user data: \(error.localizedDescription)")
      }
    }
    return appGroupUserDataURL
  }

  // Rime的ShareSupport目录
  static var sharedSupportDirectory: URL {
    try! FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      .appendingPathComponent(AppConstants.rimeSharedSupportPathName, isDirectory: true)
  }

  // Rime的userData目录
  static var userDataDirectory: URL {
    try! FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      .appendingPathComponent(AppConstants.rimeUserPathName, isDirectory: true)
  }

  // 同步安装包下的ShareSupport目录内容至Rime的ShareSupport下
  static func syncShareSupportDirectory() throws {
    let fm = FileManager.default
    let srcPath = Bundle.main.bundleURL
      .appendingPathComponent(AppConstants.rimeSharedSupportPathName, isDirectory: true)
    let dstPath = sharedSupportDirectory

    #if DEBUG
      print("copy source path: ", srcPath)
      print("copy destination path: ", dstPath)
    #endif
    if fm.fileExists(atPath: dstPath.path) {
      return
    }

    try fm.copyItem(at: srcPath, to: dstPath)
  }

  static func syncAppGroupUserDataDirectory() throws {
    let fm = FileManager.default
    let srcPath = appGroupUserDataDirectoryURL
    let dstPath = userDataDirectory

    #if DEBUG
      print("copy source path: ", srcPath)
      print("copy destination path: ", dstPath)
    #endif
    // TODO: 如果需要同步则删除Rime目录后, 从AppGroup目录下重新Copy
    // 目前测试则直接删除
    if fm.fileExists(atPath: dstPath.path) {
      try fm.removeItem(atPath: dstPath.path)
    }

    // 当源路径不存在时, 则手工创建userData目录, 并不再同步
    if !fm.fileExists(atPath: srcPath.path) {
      try fm.createDirectory(at: dstPath, withIntermediateDirectories: true)
      return
    }

    try fm.copyItem(at: srcPath, to: dstPath)
  }
}

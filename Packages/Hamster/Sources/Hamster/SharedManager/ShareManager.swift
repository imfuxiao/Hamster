//
//  File.swift
//
//
//  Created by morse on 12/1/2023.
//

import Foundation
import UIKit

class ShareManager {
  static var shareUserDefaults: UserDefaults {
    UserDefaults(suiteName: AppConstants.appGroupName)!
  }

  static var shareURL: URL {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupName)!
  }

  static var appGroupShareURL: URL {
    return shareURL.appendingPathComponent(AppConstants.shareAppGroupPath, isDirectory: true)
  }
  
  // 注意: 初始化会重写共享文件夹内容
  static func initShareResources(appAbsolutePath: URL) throws {
    let fm = FileManager.default
    let srcPath = appAbsolutePath.appendingPathComponent(AppConstants.containerAppResourcesPath, isDirectory: true)
    let dstPath = appGroupShareURL

    #if DEBUG
    print("app path: ", srcPath)
    print("share dir path: ", dstPath)
    #endif

    if fm.fileExists(atPath: dstPath.path) {
      try fm.removeItem(atPath: dstPath.path)
    }

    try fm.copyItem(at: srcPath, to: dstPath)
  }

  static func initKeyboardInputMethodResources(keyboardAbsolutePath: URL, dstDirIsOverlay isOverlay: Bool = false) throws {
    let fm = FileManager.default
    let srcPath = appGroupShareURL
    let dstPath = keyboardAbsolutePath.appendingPathComponent(AppConstants.keyboardExtentionResourcesPath, isDirectory: true)

    #if DEBUG
    print("share dir path: ", srcPath)
    print("keyboard dir path: ", dstPath)
    #endif

    let dstIsExists = fm.fileExists(atPath: dstPath.path)

    // 目标文件存在且不需要覆盖则无需操作
    if dstIsExists && !isOverlay {
      return
    }

    // 目标文件存在且需要覆盖则需先删除目标文件
    if dstIsExists && isOverlay {
      try fm.removeItem(atPath: dstPath.path)
    }
    
    // 其他情况直接复制
    try fm.copyItem(at: srcPath, to: dstPath)
  }
}

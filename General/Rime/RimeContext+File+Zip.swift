//
//  RimeContext+Zip.swift
//  Hamster
//
//  Created by morse on 20/5/2023.
//

import Foundation

extension RimeContext {
  // 初始化AppGroup共享目录下SharedSupport目录资源
  static func initAppGroupSharedSupportDirectory(override: Bool = false) throws {
    try initSharedSupportDirectory(override: override, dst: appGroupSharedSupportDirectoryURL)
  }

  // 初始化沙盒目录下SharedSupport目录资源
  static func initSandboxSharedSupportDirectory(override: Bool = false) throws {
    try initSharedSupportDirectory(override: override, dst: sandboxSharedSupportDirectory)
  }

  // 初始化 SharedSupport 目录资源
  private static func initSharedSupportDirectory(override: Bool = false, dst: URL) throws {
    let fm = FileManager()
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
    try fm.unzipItem(at: src, to: dst.deletingLastPathComponent())
  }
}
